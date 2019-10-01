/**
 * Created by AntonAntoniuk on 01.10.2019.
 */

@IsTest
private class ClientTest {
    @IsTest
    static void testBehavior() {
        FileManager YandexManager = new FileManager(new YandexDisk());
        FileManager GoogleManager = new FileManager(new GoogleDrive());
        FileManager OneDriveManager = new FileManager(new OneDrive());

        System.assertEquals(YandexManager.getFileLink(),'Get YandexDisk File Link');
        System.assertEquals(YandexManager.deleteFile(),'Delete File From YandexDisk');
        System.assertEquals(YandexManager.putFile(),'Send File To YandexDisk');

        System.assertEquals(GoogleManager.getFileLink(),'Get GoogleDrive File Link');
        System.assertEquals(GoogleManager.deleteFile(),'Delete File From GoogleDrive');
        System.assertEquals(GoogleManager.putFile(),'Send File To GoogleDrive');

        System.assertEquals(OneDriveManager.getFileLink(),'Get OneDrive File Link');
        System.assertEquals(OneDriveManager.deleteFile(),'Delete File From OneDrive');
        System.assertEquals(OneDriveManager.putFile(),'Send File To OneDrive');
    }
}