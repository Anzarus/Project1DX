/**
 * Created by AntonAntoniuk on 23.09.2019.
 */

public with sharing class CheckJobStatusUtil {

    @Future(Callout=true)
    public static void checkDeletionStatus() {
        DropBoxConnectionImpl dropBox = new DropBoxConnectionImpl();
        List<Remove_Job__c> openJobs = getOpenJobs();
        Map<String, List<String>> resultMessage;
        List<String> deletedFiles = new List<String>();

        makeCallouts(openJobs, resultMessage, dropBox, deletedFiles);
        if (!deletedFiles.isEmpty()) {
            deletingFileResources(deletedFiles);
        }
        update openJobs;
    }

    private static void makeCallouts(List<Remove_Job__c> openJobs, Map<String, List<String>> resultMessage, DropBoxConnectionImpl dropBox, List<String> deletedFiles) {
        for (Remove_Job__c job : openJobs) {
            resultMessage = dropBox.checkDeletedStatus(job.JobId__c);
            if (resultMessage != null) {
                String str = String.valueOf(resultMessage.get('result')[0]);
                job.Status__c = str;
                deletedFiles.addAll(resultMessage.get('successFiles'));
                if (job.Status__c == 'Failed') {
                    job.Error_Message__c = 'ERROR! Some files has not been deleted in DropBox, please pay attention!';
                    if (resultMessage.get('successFiles') != new List<String>()) {
                        job.Error_Message__c += ' But this files has been deleted: ' + resultMessage.get('successFiles');
                    }
                }
            }
        }
    }

    private static void deletingFileResources(List<String> deletedFiles) {
        Map<Id, Remove_Job__c> removeJobsByIds = new Map<Id, Remove_Job__c>(getOpenJobs());
        List<File_Source__c> fileSourcesToDelete = [
                SELECT Id
                FROM File_Source__c
                WHERE Name IN :deletedFiles AND Remove_Job__c IN :removeJobsByIds.keySet()
        ];
        delete fileSourcesToDelete;
    }

    private static List<Remove_Job__c> getOpenJobs() {
        List<Remove_Job__c> openJobs = [
                SELECT Id, JobId__c, Error_Message__c
                FROM Remove_Job__c
                WHERE Status__c = 'New'
        ];
        return openJobs;
    }
}