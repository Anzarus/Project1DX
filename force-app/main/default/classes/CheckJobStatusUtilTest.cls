/**
 * Created by AntonAntoniuk on 24.09.2019.
 */

@IsTest
private class CheckJobStatusUtilTest {
    @IsTest
    static void testSuccess() {
        Test.setMock(HttpCalloutMock.class, new DropBoxConnectionTestMock());

        List<Remove_Job__c> openJobs = new List<Remove_Job__c>{
                new Remove_Job__c(JobId__c = 'dbjid:AABoqpEIEjq')
        };
        insert openJobs;

        Test.startTest();
        CheckJobStatusUtil.checkDeletionStatus();
        Test.stopTest();

        Remove_Job__c removeJob = [
                SELECT Error_Message__c, Status__c
                FROM Remove_Job__c
                WHERE Id = :openJobs[0].Id
        ];

        System.assertEquals(null, removeJob.Error_Message__c);
        System.assertEquals('Success', removeJob.Status__c);
    }

    @IsTest
    static void testError() {
        Test.setMock(HttpCalloutMock.class, new DropBoxConnectionTestMock());

        List<Remove_Job__c> openJobs = new List<Remove_Job__c>{
                new Remove_Job__c(JobId__c = 'dbjid:AABoqpEIEjq1'),
                new Remove_Job__c(JobId__c = 'dbjid:other')
        };
        insert openJobs;

        Test.startTest();
        CheckJobStatusUtil.checkDeletionStatus();
        Test.stopTest();

        Map<Id, Remove_Job__c> openJobsByIds = new Map<Id, Remove_Job__c>(openJobs);
        List<Remove_Job__c> removeJobs = [
                SELECT Error_Message__c, Status__c
                FROM Remove_Job__c
                WHERE Id IN :openJobsByIds.keySet()
        ];

        System.assertEquals('ERROR! Some files has not been deleted in DropBox, ' +
                'please pay attention! But this files has been deleted: ' +
                '(/file (2).txt)', removeJobs[0].Error_Message__c);
        System.assertEquals('Failed', removeJobs[0].Status__c);
        System.assertEquals(null, removeJobs[1].Error_Message__c);
        System.assertEquals('New', removeJobs[1].Status__c);
    }

    private class DropBoxConnectionTestMock implements HttpCalloutMock {

        public HttpResponse respond(HttpRequest request) {
            HttpResponse response = new HttpResponse();
            if (request.getEndpoint() == 'callout:DropBoxGetFile/delete_batch/check') {
                if (request.getBody() == '{\"async_job_id\": \"dbjid:AABoqpEIEjq\"}') {
                    response.setStatusCode(200);
                    response.setBody('{".tag": "complete","entries": ' +
                            '[{".tag": "success",' +
                            '"metadata": {"path_display": "/file (1).txt"}},' +
                            '{".tag": "success",' +
                            '"metadata": {"path_display": "/file (3).txt"}}]}');
                } else if (request.getBody() == '{\"async_job_id\": \"dbjid:AABoqpEIEjq1\"}') {
                    response.setStatusCode(200);
                    response.setBody('{".tag": "complete","entries": ' +
                            '[{".tag": "failure",' +
                            '"failure": {".tag": "path_lookup","path_lookup": {".tag": "not_found"}}},' +
                            '{".tag": "success",' +
                            '"metadata": {"path_display": "/file (2).txt"}}]}');
                } else if (request.getBody() == '{\"async_job_id\": \"dbjid:other\"}') {
                    response.setStatusCode(200);
                    response.setBody('{".tag": "other","entries": {}}');
                } else {
                    response.setStatusCode(409);
                    response.setBody('Something went wrong!');
                }
            }
            return response;
        }
    }
}