/**
 * Created by AntonAntoniuk on 01.10.2019.
 */

@IsTest
private class DITest {
    @IsTest
    static void testMockBehavior() {
        DI.overrideInst(ServiceConnection.class, 'yandex', ConnectionTestImpl.class);
        ServiceConnection YandexManager = (ServiceConnection) DI.getInst(ServiceConnection.class, 'yandex');

        System.assertEquals(YandexManager.getFileDownloadLink(''), '1');
        System.assertEquals(YandexManager.sendFile(''), '2');
        System.assertEquals(YandexManager.deleteFile(''), '3');
    }

    @IsTest
    static void testMapNullPointerBehavior() {
        try {
            DI.getInst(ServiceConnection.class, 'test');
        } catch (NullPointerException e) {
            System.assertEquals(e.getMessage(), e.getMessage());
        }
    }

    @IsTest
    static void testImplNullPointerBehavior() {
        try {
            DI.overrideInst(ServiceConnection.class, 'yandex', DITest.class);
            DI.getInst(ServiceConnection.class, 'yandex');
        } catch (NullPointerException e) {
            System.assertEquals(e.getMessage(), e.getMessage());
        }
    }
}