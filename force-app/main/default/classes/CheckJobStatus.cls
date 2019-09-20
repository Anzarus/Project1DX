/**
 * Created by AntonAntoniuk on 20.09.2019.
 */

public with sharing class CheckJobStatus implements Schedulable {

    public void execute(SchedulableContext param1) {
        DropBoxConnection dropBox = new DropBoxConnection();
        List<Remove_Job__c> openJobs = [
                SELECT Id, JobId__c, Error_Message__c
                FROM Remove_Job__c
                WHERE Status__c = 'New'
        ];

        Map<String, List<String>> resultMessage;
        for (Remove_Job__c job : openJobs) {
            resultMessage = dropBox.checkDeletedStatus(job.JobId__c);
            if (resultMessage != null) {
                job.Status__c = String.valueOf(resultMessage.get('result')[0]);
                if (job.Status__c == 'Failed') {
                    job.Error_Message__c = 'ERROR! Some files has not been deleted in DropBox, please pay attention!';
                    if (resultMessage.get('successFiles') != new List<String>()) {
                        job.Error_Message__c += ' But this files has been deleted: ' + resultMessage.get('successFiles');
                    }
                }
            }
        }
        update openJobs;
    }
}