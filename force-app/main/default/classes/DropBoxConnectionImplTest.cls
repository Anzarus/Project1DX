/**
 * Created by AntonAntoniuk on 13.09.2019.
 */

@IsTest
private class DropBoxConnectionImplTest {
    @IsTest
    static void getLinkSuccessTest() {
        HttpResponse response = new HttpResponse();
        response.setStatusCode(200);
        response.setBody('{"metadata": {}, "link": "https://dl.dropboxusercontent.com/apitl/1/Doc"}');

        Test.setMock(HttpCalloutMock.class, new DropBoxConnectionTestMock(response));

        Test.startTest();
        String link = new DropBoxConnectionImpl().getDownloadLink('/Document.docx');
        Test.stopTest();

        System.assertEquals('https://dl.dropboxusercontent.com/apitl/1/Doc', link);
    }

    @IsTest
    static void getLinkErrorTest() {
        HttpResponse response = new HttpResponse();
        response.setStatusCode(404);
        response.setBody('Something went wrong!');

        Test.setMock(HttpCalloutMock.class, new DropBoxConnectionTestMock(response));

        try {
            Test.startTest();
            new DropBoxConnectionImpl().getDownloadLink('Documentdocx');
            Test.stopTest();
        } catch (DropBoxConnectionImpl.DropBoxConnectionException e) {
            System.assertEquals('File not found!', e.getMessage());
        }
    }

    @IsTest
    static void getLinkErrorNotFoundTest() {
        HttpResponse response = new HttpResponse();
        response.setStatusCode(409);
        response.setBody('Something went wrong!');

        Test.setMock(HttpCalloutMock.class, new DropBoxConnectionTestMock(response));

        try {
            Test.startTest();
            new DropBoxConnectionImpl().getDownloadLink('/');
            Test.stopTest();
        } catch (DropBoxConnectionImpl.DropBoxConnectionException e) {
            System.assertEquals('Something went wrong!', e.getMessage());
        }
    }

    @IsTest
    static void deleteSuccessTest() {
        HttpResponse response = new HttpResponse();
        response.setStatusCode(200);
        response.setBody('{".tag": "async_job_id", "async_job_id": "dbjid:AABoqpEIEjq"}');

        Test.setMock(HttpCalloutMock.class, new DropBoxConnectionTestMock(response));

        Test.startTest();
        String jobId = new DropBoxConnectionImpl().deleteFiles(new List<String>{
                '/file (2).txt', '/file (1).txt', '/file (1) (1).txt'
        });
        Test.stopTest();

        System.assertEquals('dbjid:AABoqpEIEjq', jobId);
    }

    @IsTest
    static void deleteErrorTest() {
        HttpResponse response = new HttpResponse();
        response.setStatusCode(409);
        response.setBody('Something went wrong!');

        Test.setMock(HttpCalloutMock.class, new DropBoxConnectionTestMock(response));

        try {
            Test.startTest();
            new DropBoxConnectionImpl().deleteFiles(new List<String>{
                    '', '/file (1).txt', '/file (1) (1).txt'
            });
            Test.stopTest();
        } catch (DropBoxConnectionImpl.DropBoxConnectionException e) {
            System.assertEquals('Something went wrong!', e.getMessage());
        }
    }

    @IsTest
    static void deleteCheckCompleteSuccessTest() {
        HttpResponse response = new HttpResponse();
        response.setStatusCode(200);
        response.setHeader('Content-Type', 'application/json');
        response.setBody('{".tag": "complete","entries": [{".tag": "success"...}]}');

        Test.setMock(HttpCalloutMock.class, new DropBoxConnectionTestMock(response));

        Test.startTest();
        Map<String, String> resultFullSuccess = new DropBoxConnectionImpl().checkDeletedStatus('jobId:success');
        Test.stopTest();

        System.assertEquals(
                new Map<String, String>{
                        'RequestBody' => '{\"async_job_id\": \"jobId:success\"}',
                        'RequestHeader' => JSON.serialize(new Map<String, String>{
                                'Content-Type' => 'application/json'
                        }),
                        'ResponseBody' => '{".tag": "complete","entries": [{".tag": "success"...}]}',
                        'ResponseHeader' => JSON.serialize(new Map<String, String>{
                                'Content-Type' => 'application/json'
                        }),
                        'StatusCode' => '200',
                        'Url' => 'callout:DropBoxGetFile/delete_batch/check'
                },
                resultFullSuccess);
    }

    @IsTest
    static void deleteCheckCompleteFailureTest() {
        HttpResponse response = new HttpResponse();
        response.setStatusCode(200);
        response.setBody('{".tag": "complete","entries": [{".tag": "failure"...}]}');

        Test.setMock(HttpCalloutMock.class, new DropBoxConnectionTestMock(response));

        Test.startTest();
        Map<String, String> resultPartSuccess = new DropBoxConnectionImpl().checkDeletedStatus('jobId:error');
        Test.stopTest();

        System.assertEquals(
                new Map<String, String>{
                        'RequestBody' => '{\"async_job_id\": \"jobId:error\"}',
                        'RequestHeader' => JSON.serialize(new Map<String, String>{
                                'Content-Type' => 'application/json'
                        }),
                        'ResponseBody' => '{".tag": "complete","entries": [{".tag": "failure"...}]}',
                        'ResponseHeader' => '{}',
                        'StatusCode' => '200',
                        'Url' => 'callout:DropBoxGetFile/delete_batch/check'
                },
                resultPartSuccess);
    }

    @IsTest
    static void deleteCheckOtherTest() {
        HttpResponse response = new HttpResponse();
        response.setStatusCode(200);
        response.setBody('{".tag": "other","entries": {}}');

        Test.setMock(HttpCalloutMock.class, new DropBoxConnectionTestMock(response));

        Test.startTest();
        Map<String, String> resultOther = new DropBoxConnectionImpl().checkDeletedStatus('jobId:other');
        Test.stopTest();

        System.assertEquals(
                new Map<String, String>{
                        'RequestBody' => '{\"async_job_id\": \"jobId:other\"}',
                        'RequestHeader' => JSON.serialize(new Map<String, String>{
                                'Content-Type' => 'application/json'
                        }),
                        'ResponseBody' => '{".tag": "other","entries": {}}',
                        'ResponseHeader' => '{}',
                        'StatusCode' => '200',
                        'Url' => 'callout:DropBoxGetFile/delete_batch/check'
                },
                resultOther);
    }

    @IsTest
    static void deleteCheckErrorTest() {
        HttpResponse response = new HttpResponse();
        response.setStatusCode(409);
        response.setBody('Something went wrong!');

        Test.setMock(HttpCalloutMock.class, new DropBoxConnectionTestMock(response));

        try {
            Test.startTest();
            new DropBoxConnectionImpl().checkDeletedStatus('');
            Test.stopTest();
        } catch (DropBoxConnectionImpl.DropBoxConnectionException e) {
            System.assertEquals('Something went wrong!', e.getMessage());
        }
    }

    private class DropBoxConnectionTestMock implements HttpCalloutMock {

        HttpResponse httpResponse;

        private DropBoxConnectionTestMock(HttpResponse httpResponse) {
            this.httpResponse = httpResponse;
        }

        public HttpResponse respond(HttpRequest request) {
            return this.httpResponse;
        }
    }
}