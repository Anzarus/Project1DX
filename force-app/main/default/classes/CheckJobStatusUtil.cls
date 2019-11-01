/**
 * Created by AntonAntoniuk on 24.09.2019.
 */

public with sharing class CheckJobStatusUtil implements Queueable, Database.AllowsCallouts {

    private List<Remove_Job__c> openJobs;

    public CheckJobStatusUtil() {
        this.openJobs = getOpenJobs();
    }

    private List<Remove_Job__c> getOpenJobs() {
        List<Remove_Job__c> openJobs = [
                SELECT Id, JobId__c, Error_Message__c
                FROM Remove_Job__c
                WHERE Status__c = 'New'
                LIMIT 50
        ];
        return openJobs;
    }

    public void execute(QueueableContext param1) {
        DropBoxConnectionImpl dropBox = new DropBoxConnectionImpl();
        HttpLogger httpLogger = new HttpLogger();
        List<Map<String, String>> calloutsResults = makeCallouts(dropBox);

        for (Integer i = 0; i < calloutsResults.size(); i++) {
            httpLogger.logHttpUsingPlatformEvent(calloutsResults[i]);
            analyzeRequest(calloutsResults[i], openJobs[i]);
        }
        update openJobs;

        if (![SELECT Id FROM Remove_Job__c WHERE Status__c = 'New' LIMIT 1].isEmpty()) {
            System.enqueueJob(new CheckJobStatusUtil());
        }//todo redo to make a few record requests
    }

    private void analyzeRequest(Map<String, String> calloutResult, Remove_Job__c openJob) {
        Map<String, List<String>> deletionReport = formDeletionReport(calloutResult.get('ResponseBody'));
        if (deletionReport != null) {
            String str = String.valueOf(deletionReport.get('result')[0]);
            openJob.Status__c = str;
            if (openJob.Status__c == 'Failed') {
                openJob.Error_Message__c = 'ERROR! Some files has not been deleted in DropBox, please pay attention!';
                if (deletionReport.get('successFiles') != new List<String>()) {
                    openJob.Error_Message__c += ' But this files has been deleted: ' + deletionReport.get('successFiles');
                }
            }
        }
    }

    private List<Map<String, String>> makeCallouts(DropBoxConnectionImpl dropBox) {
        List<Map<String, String>> calloutsResults = new List<Map<String, String>>();
        for (Remove_Job__c job : openJobs) {
            calloutsResults.add(dropBox.checkDeletedStatus(job.JobId__c));
        }
        return calloutsResults;
    }

    private Map<String, List<String>> formDeletionReport(String responseBody) {
        Map<String, Object> resultMap = (Map<String, Object>) JSON.deserializeUntyped(responseBody);
        String resultMessage = String.valueOf(resultMap.get('.tag'));
        if (resultMessage == 'complete') {
            List<Object> entries = (List<Object>) resultMap.get('entries');
            return formFileDeletionResult(entries);
        }
        return null;
    }

    private Map<String, List<String>> formFileDeletionResult(List<Object> entries) {
        Map<String, Object> fileStatus;
        List<String> successDeletedFiles = new List<String>();
        for (Object obj : entries) {
            fileStatus = (Map<String, Object>) obj;
            if (fileStatus.get('.tag') == 'success') {
                Map<String, Object> metadata = (Map<String, Object>) fileStatus.get('metadata');
                successDeletedFiles.add(String.valueOf(metadata.get('path_display')));
            }
        }
        System.debug(successDeletedFiles);
        if (successDeletedFiles.size() == entries.size()) {
            return new Map<String, List<String>>{
                    'result' => new List<String>{
                            'Success'
                    },
                    'successFiles' => successDeletedFiles
            };
        } else {
            return new Map<String, List<String>>{
                    'result' => new List<String>{
                            'Failed'
                    },
                    'successFiles' => successDeletedFiles
            };
        }
    }
}