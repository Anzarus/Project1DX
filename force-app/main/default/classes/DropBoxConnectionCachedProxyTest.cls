/**
 * Created by AntonAntoniuk on 04.11.2019.
 */

@IsTest
private class DropBoxConnectionCachedProxyTest {
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
                }
            }
            return response;
        }
    }
}