/**
 * Created by AntonAntoniuk on 04.11.2019.
 */

@IsTest
private class DropBoxConnectionCachedProxyTest {
    @IsTest
    static void getLinkProxyWithCacheTest() {
        DropBoxConnection connection = (DropBoxConnectionImpl) Test.createStub(DropBoxConnectionImpl.class, new MockProvider());
        DropBoxConnectionCachedProxy connectionProxy = new DropBoxConnectionCachedProxy(connection);
        connectionProxy.cache = (CacheController) Test.createStub(CacheController.class, new MockProvider());

        String result = connectionProxy.getDownloadLink('/Document.docx');

        System.assertEquals('https://dl.dropboxusercontent.com/apitl/1/Doc', result);
    }

    @IsTest
    static void getLinkProxyWithoutCacheTest() {
        DropBoxConnection connection = (DropBoxConnectionImpl) Test.createStub(DropBoxConnectionImpl.class, new MockProvider());
        DropBoxConnectionCachedProxy connectionProxy = new DropBoxConnectionCachedProxy(connection);
        connectionProxy.cache = (CacheController) Test.createStub(CacheController.class, new MockProvider());

        String result = connectionProxy.getDownloadLink('/Test1.1.odt');

        System.assertEquals('https://dl.dropboxusercontent.com/apitl/1/Odt', result);
    }
}