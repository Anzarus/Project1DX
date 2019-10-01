/**
 * Created by AntonAntoniuk on 01.10.2019.
 */

@IsTest
private class ClientTest {
    @IsTest
    static void testBehavior() {
        ServiceConnection YandexManager = DI.getInst(ServiceConnection.class, 'yandex');
        ServiceConnection GoogleManager = DI.getInst(ServiceConnection.class, 'google');
        ServiceConnection OneDriveManager = DI.getInst(ServiceConnection.class, 'oneDrive');

        System.assertEquals(YandexManager.getFileDownloadLink(''),'Get YandexDisk File Link');
        System.assertEquals(YandexManager.deleteFile(''),'Delete File From YandexDisk');
        System.assertEquals(YandexManager.sendFile(''),'Send File To YandexDisk');

        System.assertEquals(GoogleManager.getFileDownloadLink(''),'Get GoogleDrive File Link');
        System.assertEquals(GoogleManager.deleteFile(''),'Delete File From GoogleDrive');
        System.assertEquals(GoogleManager.sendFile(''),'Send File To GoogleDrive');

        System.assertEquals(OneDriveManager.getFileDownloadLink(''),'Get OneDrive File Link');
        System.assertEquals(OneDriveManager.deleteFile(''),'Delete File From OneDrive');
        System.assertEquals(OneDriveManager.sendFile(''),'Send File To OneDrive');
    }
}