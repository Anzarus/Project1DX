/**
 * Created by AntonAntoniuk on 24.09.2019.
 */

public with sharing class DropBoxCheckRemoveStatusJob implements Queueable, Database.AllowsCallouts {

    private static String ERR_SOME_FILES_HAVE_NOT_DEL = 'ERROR! Some files has not been deleted in DropBox, please pay attention! ';
    private static String SOME_FILES_WERE_DEL = 'But this files has been deleted: {0}';
    private static String ERR_SOMETHING_STRANGE = 'ERROR! Please pay attention to the deletion job with id: {0} ! Cause something wrong happens!';

    private List<Remove_Job__c> totalOpenJobs;
    private List<Remove_Job__c> currentOpenJobs;
    private Boolean recursive;

    public DropBoxCheckRemoveStatusJob() {
        this.totalOpenJobs = getOpenJobs();
        this.currentOpenJobs = getOpenJobsForCurrentQueueable();
        this.recursive = getRecursiveSetting();
    }

    public DropBoxCheckRemoveStatusJob(List<Remove_Job__c> openJobs) {
        this.totalOpenJobs = openJobs;
        this.currentOpenJobs = getOpenJobsForCurrentQueueable();
        this.recursive = getRecursiveSetting();
    }

    private List<Remove_Job__c> getOpenJobs() {
        List<Remove_Job__c> openJobs = [
                SELECT Id, JobId__c, Error_Message__c
                FROM Remove_Job__c
                WHERE Status__c = 'New'
                LIMIT 2500
        ];
        return openJobs;
    }

    private Boolean getRecursiveSetting() {
        return [
                SELECT IsEnabled__c
                FROM IsEnabled__c
                WHERE Name = 'CheckJobStatusQueueable'
                LIMIT 1
        ].IsEnabled__c;
    }

    private List<Remove_Job__c> getOpenJobsForCurrentQueueable() {
        List<Remove_Job__c> removeJobs = new List<Remove_Job__c>();
        for (Integer i = 0; i < 50 && i < totalOpenJobs.size(); i++) {
            removeJobs.add(totalOpenJobs[i]);
        }
        return removeJobs;
    }

    public void execute(QueueableContext param1) {
        if (currentOpenJobs.size() == 0) return;

        DropBoxConnectionImpl dropBox = new DropBoxConnectionImpl();
        HttpLogger httpLogger = new HttpLogger();
        List<Map<String, String>> calloutsResults = makeCallouts(dropBox);

        for (Integer i = 0; i < calloutsResults.size(); i++) {
            httpLogger.logHttpUsingPlatformEvent(calloutsResults[i]);
            analyzeRequest(calloutsResults[i], currentOpenJobs[i]);
        }
        update currentOpenJobs;

        List<Remove_Job__c> totalJobsWithOutCurrentJobs = getTotalJobsWithoutCurrent(totalOpenJobs, currentOpenJobs);

        if (recursive
                && !totalJobsWithOutCurrentJobs.isEmpty()
                && !Test.isRunningTest()) {
            System.enqueueJob(new DropBoxCheckRemoveStatusJob(totalJobsWithOutCurrentJobs));
        }
    }

    private List<Map<String, String>> makeCallouts(DropBoxConnectionImpl dropBox) {
        List<Map<String, String>> calloutsResults = new List<Map<String, String>>();
        for (Remove_Job__c job : currentOpenJobs) {
            calloutsResults.add(dropBox.checkDeletedStatus(job.JobId__c));
        }
        return calloutsResults;
    }

    private void analyzeRequest(Map<String, String> calloutResult, Remove_Job__c openJob) {
        Map<String, List<String>> deletionReport = formDeletionReport(calloutResult.get('ResponseBody'));
        if (deletionReport != null) {
            String str = String.valueOf(deletionReport.get('result')[0]);
            openJob.Status__c = str;
            if (openJob.Status__c == 'Failed') {
                openJob.Error_Message__c = ERR_SOME_FILES_HAVE_NOT_DEL;
                if (deletionReport.get('successFiles') != new List<String>()) {
                    openJob.Error_Message__c += String.format(SOME_FILES_WERE_DEL, deletionReport.get('successFiles'));
                }
            } else if (openJob.Status__c == 'Other') {
                openJob.Error_Message__c = String.format(ERR_SOMETHING_STRANGE, new List<Object>{
                        openJob.JobId__c
                });
            }
        }
    }

    private Map<String, List<String>> formDeletionReport(String responseBody) {
        Map<String, Object> resultMap = (Map<String, Object>) JSON.deserializeUntyped(responseBody);
        String resultMessage = String.valueOf(resultMap.get('.tag'));
        if (resultMessage == 'complete') {
            List<Object> entries = (List<Object>) resultMap.get('entries');
            return formFileDeletionResult(entries);
        } else if (resultMessage == 'other') {
            return new Map<String, List<String>>{
                    'result' => new List<String>{
                            'Other'
                    }
            };
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

    private List<Remove_Job__c> getTotalJobsWithoutCurrent(List<Remove_Job__c> defaultJobs, List<Remove_Job__c> jobsToRemove) {
        List<Remove_Job__c>resultList = new List<Remove_Job__c>();
        Map<Id, Remove_Job__c> jobsToRemoveByIds = new Map<Id, Remove_Job__c>(jobsToRemove);
        for (Remove_Job__c job : defaultJobs) {
            if (jobsToRemoveByIds.containsKey(job.Id)) continue;
            resultList.add(job);
        }
        return resultList;
    }
}