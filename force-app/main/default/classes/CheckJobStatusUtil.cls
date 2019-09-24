/**
 * Created by AntonAntoniuk on 24.09.2019.
 */

public with sharing class CheckJobStatusUtil {

    @Future(Callout=true)
    public static void checkDeletionStatus() {
        DropBoxConnectionImpl dropBox = new DropBoxConnectionImpl();
        List<Remove_Job__c> openJobs = getOpenJobs();
        Map<String, List<String>> resultMessage;

        makeCallouts(openJobs, resultMessage, dropBox);
        update openJobs;
    }

    private static void makeCallouts(List<Remove_Job__c> openJobs,
            Map<String, List<String>> resultMessage,
            DropBoxConnectionImpl dropBox) {

        for (Remove_Job__c job : openJobs) {
            resultMessage = dropBox.checkDeletedStatus(job.JobId__c);
            if (resultMessage != null) {
                String str = String.valueOf(resultMessage.get('result')[0]);
                job.Status__c = str;
                if (job.Status__c == 'Failed') {
                    job.Error_Message__c = 'ERROR! Some files has not been deleted in DropBox, please pay attention!';
                    if (resultMessage.get('successFiles') != new List<String>()) {
                        job.Error_Message__c += ' But this files has been deleted: ' + resultMessage.get('successFiles');
                    }
                }
            }
        }
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