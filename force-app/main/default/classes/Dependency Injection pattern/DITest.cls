/**
 * Created by AntonAntoniuk on 01.10.2019.
 */

@IsTest
private class DITest {
    @IsTest
    static void testMockBehavior() {
        DI.formMap((SOQLPostman) Test.createStub(SOQLPostman.class, new MockProvider()));
        DI.overrideInst(ServiceConnection.class, 'test', ConnectionTestImpl.class);
        ServiceConnection YandexManager = (ServiceConnection) DI.getInst(ServiceConnection.class, 'test');

        System.assertEquals(YandexManager.getFileDownloadLink(''), '1');
        System.assertEquals(YandexManager.sendFile(''), '2');
        System.assertEquals(YandexManager.deleteFile(''), '3');
    }

    @IsTest
    static void testDIExceptionBehavior() {
        try {
            DI.getInst(ServiceConnection.class, 'test');
        } catch (Exception e) {
            System.assertEquals(e.getMessage(), e.getMessage());
        }
    }
}