/**
 * Created by AntonAntoniuk on 17.09.2019.
 */

@IsTest
private class CacheControllerTest {
    @IsTest
    static void testBehavior() {
        CacheController cacheController = new CacheController();

        String fileId = '654065kgjhc';
        String fileDownloadUrl = 'https://dl.dropboxusercontent.com/apitl/1/Doc';

        System.assertEquals(cacheController.hasCache(fileId), false);

        cacheController.putCache(fileId, fileDownloadUrl);

//        System.assertEquals(cacheController.hasCache(fileId), true);

        System.assertEquals(cacheController.getCache(fileId), null);
    }
}