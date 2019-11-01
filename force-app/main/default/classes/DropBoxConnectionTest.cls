/**
 * Created by AntonAntoniuk on 13.09.2019.
 */

@IsTest
private class DropBoxConnectionTest {
    @IsTest
    static void getLinkSuccessTest() {
        Test.setMock(HttpCalloutMock.class, new DropBoxConnectionTestMock());

        Test.startTest();
        String link = new DropBoxConnectionImpl().getDownloadLink('/Document.docx');
        Test.stopTest();

        System.assertEquals('https://dl.dropboxusercontent.com/apitl/1/Doc', link);
    }

    @IsTest
    static void getLinkErrorTest() {
        Test.setMock(HttpCalloutMock.class, new DropBoxConnectionTestMock());
        try {
            Test.startTest();
            new DropBoxConnectionImpl().getDownloadLink('Documentdocx');
            Test.stopTest();
        } catch (DropBoxConnectionImpl.DropBoxConnectionException e) {
            System.assertEquals(e.getMessage(), e.getMessage());
        }
    }

    @IsTest
    static void getLinkErrorNotFoundTest() {
        Test.setMock(HttpCalloutMock.class, new DropBoxConnectionTestMock());
        try {
            Test.startTest();
            new DropBoxConnectionImpl().getDownloadLink('/');
            Test.stopTest();
        } catch (DropBoxConnectionImpl.DropBoxConnectionException e) {
            System.assertEquals(e.getMessage(), e.getMessage());
        }
    }

    @IsTest
    static void deleteSuccessTest() {
        Test.setMock(HttpCalloutMock.class, new DropBoxConnectionTestMock());

        Test.startTest();
        String link = new DropBoxConnectionImpl().deleteFiles(new List<String>{
                '/file (2).txt', '/file (1).txt', '/file (1) (1).txt'
        });
        Test.stopTest();

        System.assertEquals('dbjid:AABoqpEIEjq', link);
    }
    @IsTest
    static void deleteErrorTest() {
        Test.setMock(HttpCalloutMock.class, new DropBoxConnectionTestMock());
        try {
            Test.startTest();
            new DropBoxConnectionImpl().deleteFiles(new List<String>{
                    '', '/file (1).txt', '/file (1) (1).txt'
            });
            Test.stopTest();
        } catch (DropBoxConnectionImpl.DropBoxConnectionException e) {
            System.assertEquals(e.getMessage(), e.getMessage());
        }
    }

    @IsTest
    static void deleteCheckCompleteTest() {
        Test.setMock(HttpCalloutMock.class, new DropBoxConnectionTestMock());

        Test.startTest();
        Map<String, String> resultFullSuccess = new DropBoxConnectionImpl().checkDeletedStatus('dbjid:AABoqpEIEjq');
        Map<String, String> resultPartSuccess = new DropBoxConnectionImpl().checkDeletedStatus('dbjid:AABoqpEIEjq1');
        Map<String, String> resultOther = new DropBoxConnectionImpl().checkDeletedStatus('dbjid:other');
        Test.stopTest();

        System.assertEquals(
                new Map<String, String>{
                        'RequestBody' => '{\"async_job_id\": \"dbjid:AABoqpEIEjq\"}',
                        'RequestHeader' => 'application/json',
                        'ResponseBody' => '{".tag": "complete","entries": [{".tag": "success"...}]}',
                        'ResponseHeader' => '()',
                        'StatusCode' => '200',
                        'Url' => 'callout:DropBoxGetFile/delete_batch/check'
                },
                resultFullSuccess);
        System.assertEquals(
                new Map<String, String>{
                        'RequestBody' => '{\"async_job_id\": \"dbjid:AABoqpEIEjq1\"}',
                        'RequestHeader' => 'application/json',
                        'ResponseBody' => '{".tag": "complete","entries": [{".tag": "failure"...}]}',
                        'ResponseHeader' => '()',
                        'StatusCode' => '200',
                        'Url' => 'callout:DropBoxGetFile/delete_batch/check'
                },
                resultPartSuccess);
        System.assertEquals(
                new Map<String, String>{
                        'RequestBody' => '{\"async_job_id\": \"dbjid:other\"}',
                        'RequestHeader' => 'application/json',
                        'ResponseBody' => '{".tag": "other","entries": {}}',
                        'ResponseHeader' => '()',
                        'StatusCode' => '200',
                        'Url' => 'callout:DropBoxGetFile/delete_batch/check'
                },
                resultOther);
    }

    @IsTest
    static void deleteCheckErrorTest() {
        Test.setMock(HttpCalloutMock.class, new DropBoxConnectionTestMock());
        try {
            Test.startTest();
            new DropBoxConnectionImpl().checkDeletedStatus('');
            Test.stopTest();
        } catch (DropBoxConnectionImpl.DropBoxConnectionException e) {
            System.assertEquals(e.getMessage(), e.getMessage());
        }
    }

    @IsTest
    static void getLinkProxyTest() {
        Test.setMock(HttpCalloutMock.class, new DropBoxConnectionTestMock());

        DropBoxConnectionCachedProxy connectionProxy = new DropBoxConnectionCachedProxy(new DropBoxConnectionImpl());
        connectionProxy.cache = (CacheController) Test.createStub(CacheController.class, new MockProvider());

        String firstResult = connectionProxy.getDownloadLink('/Document.docx');
        String secondResult = connectionProxy.getDownloadLink('/Test1.1.odt');

        System.assertEquals('https://dl.dropboxusercontent.com/apitl/1/Doc', firstResult);
        System.assertEquals('https://dl.dropboxusercontent.com/apitl/1/Odt', secondResult);

    }

    private class DropBoxConnectionTestMock implements HttpCalloutMock {

        public HttpResponse respond(HttpRequest request) {
            HttpResponse response = new HttpResponse();
            if (request.getEndpoint() == 'callout:DropBoxGetFile/get_temporary_link') {
                if (request.getBody() == '{\"path\": \"/Document.docx\"}') {
                    response.setStatusCode(200);
                    response.setBody('{"metadata": {}, "link": "https://dl.dropboxusercontent.com/apitl/1/Doc"}');
                } else if (request.getBody() == '{\"path\": \"/Test1.1.odt\"}') {
                    response.setStatusCode(200);
                    response.setBody('{"metadata": {}, "link": "https://dl.dropboxusercontent.com/apitl/1/Odt"}');
                } else if (request.getBody() == '{\"path\": \"/\"}') {
                    response.setStatusCode(404);
                    response.setBody('Something went wrong!');
                } else {
                    response.setStatusCode(409);
                    response.setBody('Something went wrong!');
                }
            } else if (request.getEndpoint() == 'callout:DropBoxGetFile/delete_batch') {
                if (request.getBody() == '{\"entries\": [{\"path\": \"/file (2).txt\"}, ' +
                        '{\"path\": \"/file (1).txt\"}, ' +
                        '{\"path\": \"/file (1) (1).txt\"}]}') {
                    response.setStatusCode(200);
                    response.setBody('{".tag": "async_job_id", "async_job_id": "dbjid:AABoqpEIEjq"}');
                } else {
                    response.setStatusCode(409);
                    response.setBody('Something went wrong!');
                }
            } else if (request.getEndpoint() == 'callout:DropBoxGetFile/delete_batch/check') {
                if (request.getBody() == '{\"async_job_id\": \"dbjid:AABoqpEIEjq\"}') {
                    response.setStatusCode(200);
                    response.setBody('{".tag": "complete","entries": [{".tag": "success"...}]}');
                } else if (request.getBody() == '{\"async_job_id\": \"dbjid:AABoqpEIEjq1\"}') {
                    response.setStatusCode(200);
                    response.setBody('{".tag": "complete","entries": [{".tag": "failure"...}]}');
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