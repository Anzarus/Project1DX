/**
 * Created by AntonAntoniuk on 24.09.2019.
 */

@IsTest
private class DropBoxFileLinkFabricTest {
    @IsTest
    static void defaultConnectionTest() {
        Test.setMock(HttpCalloutMock.class, new DropBoxConnectionTestMock());
        Product2Cache__c testCacheSettings = new Product2Cache__c(
                Name = 'Product2FileUrl',
                isCacheTemporraryLink__c = false);
        insert testCacheSettings;

        Test.startTest();
        DropBoxFileLinkFabric fabric = new DropBoxFileLinkFabric();
        DropBoxConnectionImpl connection = (DropBoxConnectionImpl) fabric.getDropBoxConnector();
        String result = connection.getDownloadLink('/Document.docx');
        Test.stopTest();

        System.assertEquals('https://dl.dropboxusercontent.com/apitl/1/Doc', result);
    }

    @IsTest
    static void proxyConnectionTest() {
        Test.setMock(HttpCalloutMock.class, new DropBoxConnectionTestMock());
        Product2Cache__c testCacheSettings = new Product2Cache__c(
                Name = 'Product2FileUrl',
                isCacheTemporraryLink__c = true);
        insert testCacheSettings;

        Test.startTest();
        DropBoxFileLinkFabric fabric = new DropBoxFileLinkFabric();
        DropBoxConnectionCachedProxy connectionProxy = (DropBoxConnectionCachedProxy) fabric.getDropBoxConnector();
        connectionProxy.cache = (CacheController) Test.createStub(CacheController.class, new MockProvider());
        String result = connectionProxy.getDownloadLink('/Document.docx');
        Test.stopTest();

        System.assertEquals('https://dl.dropboxusercontent.com/apitl/1/Doc', result);

    }

    private class DropBoxConnectionTestMock implements HttpCalloutMock {

        public HttpResponse respond(HttpRequest request) {
            HttpResponse response = new HttpResponse();
            if (request.getBody() == '{\"path\": \"/Document.docx\"}') {
                response.setStatusCode(200);
                response.setBody('{"metadata": {}, "link": "https://dl.dropboxusercontent.com/apitl/1/Doc"}');
            } else {
                response.setStatusCode(409);
                response.setBody('Something went wrong!');
            }
            return response;
        }
    }
}