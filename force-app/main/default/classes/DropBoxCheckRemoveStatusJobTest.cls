/**
 * Created by AntonAntoniuk on 24.09.2019.
 */

@IsTest
private class DropBoxCheckRemoveStatusJobTest {
    @TestSetup
    static void createTestData(){
        insert new IsEnabled__c(Name = 'CheckJobStatusQueueable', IsEnabled__c = true);
    }

    @IsTest
    static void testSuccess() {
        Test.setMock(HttpCalloutMock.class, new DropBoxConnectionTestMock());

        List<Remove_Job__c> openJobs = new List<Remove_Job__c>();
        for (Integer i = 0; i < 250; i++) {
            openJobs.add(new Remove_Job__c(JobId__c = 'jobId:success' + i));
        }
        insert openJobs;


        Test.startTest();
        DropBoxCheckRemoveStatusJob checkJobStatusUtil = new DropBoxCheckRemoveStatusJob();
        System.enqueueJob(checkJobStatusUtil);
        Test.stopTest();

        List<Remove_Job__c> removeJobs = [
                SELECT Error_Message__c, Status__c
                FROM Remove_Job__c
                WHERE Status__c = 'Success'
        ];

        System.assertEquals(50, removeJobs.size());
        for (Remove_Job__c removeJob : removeJobs) {
            System.assertEquals(null, removeJob.Error_Message__c);
        }
    }

    @IsTest
    static void testError() {
        Test.setMock(HttpCalloutMock.class, new DropBoxConnectionTestMock());

        List<Remove_Job__c> openJobs = new List<Remove_Job__c>{
                new Remove_Job__c(JobId__c = 'jobId:error'),
                new Remove_Job__c(JobId__c = 'jobId:other'),
                new Remove_Job__c(JobId__c = 'jobId:inProgress')
        };
        insert openJobs;

        Test.startTest();
        DropBoxCheckRemoveStatusJob checkJobStatusUtil = new DropBoxCheckRemoveStatusJob(openJobs);
        System.enqueueJob(checkJobStatusUtil);
        Test.stopTest();

        Map<Id, Remove_Job__c> openJobsByIds = new Map<Id, Remove_Job__c>(openJobs);
        List<Remove_Job__c> removeJobs = [
                SELECT Error_Message__c, Status__c
                FROM Remove_Job__c
                WHERE Id IN :openJobsByIds.keySet()
        ];

        System.assertEquals('ERROR! Some files has not been deleted in DropBox, ' +
                'please pay attention! But this files has been deleted: ' +
                '/file (2).txt', removeJobs[0].Error_Message__c);
        System.assertEquals('Failed', removeJobs[0].Status__c);
        System.assertEquals('ERROR! Please pay attention to the deletion job with ' +
                'id: jobId:other ! Cause something wrong happens!', removeJobs[1].Error_Message__c);
        System.assertEquals('Other', removeJobs[1].Status__c);
        System.assertEquals(null, removeJobs[2].Error_Message__c);
        System.assertEquals('New', removeJobs[2].Status__c);
    }

    private class DropBoxConnectionTestMock implements HttpCalloutMock {

        public HttpResponse respond(HttpRequest request) {
            HttpResponse response = new HttpResponse();
            if (request.getEndpoint() == 'callout:DropBoxGetFile/delete_batch/check') {
                if (request.getBody().startsWith('{\"async_job_id\": \"jobId:success')
                        && request.getBody().endsWith('\"}')) {
                    response.setStatusCode(200);
                    response.setBody('{".tag": "complete","entries": ' +
                            '[{".tag": "success",' +
                            '"metadata": {"path_display": "/file (1).txt"}},' +
                            '{".tag": "success",' +
                            '"metadata": {"path_display": "/file (3).txt"}}]}');
                } else if (request.getBody() == '{\"async_job_id\": \"jobId:error\"}') {
                    response.setStatusCode(200);
                    response.setBody('{".tag": "complete","entries": ' +
                            '[{".tag": "failure",' +
                            '"failure": {".tag": "path_lookup","path_lookup": {".tag": "not_found"}}},' +
                            '{".tag": "success",' +
                            '"metadata": {"path_display": "/file (2).txt"}}]}');
                } else if (request.getBody() == '{\"async_job_id\": \"jobId:other\"}') {
                    response.setStatusCode(200);
                    response.setBody('{".tag": "other","entries": {}}');
                } else if (request.getBody() == '{\"async_job_id\": \"jobId:inProgress\"}') {
                    response.setStatusCode(200);
                    response.setBody('{".tag": "inProgress","entries": {}}');
                } else {
                    response.setStatusCode(409);
                    response.setBody('Something went wrong!');
                }
            }
            return response;
        }
    }
}