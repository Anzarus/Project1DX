/**
 * Created by AntonAntoniuk on 13.09.2019.
 */

@IsTest
private class DropBoxConnectionTest {
    @IsTest
    static void getLinkSuccessTest() {
        Test.setMock(HttpCalloutMock.class, new DropBoxConnectionTestMock());
        String link = new DropBoxConnection().getDownloadLink('Document.docx');

        Test.startTest();
        System.assertEquals('https://dl.dropboxusercontent.com/apitl/1/AKed', link);
        Test.stopTest();
    }

    @IsTest
    static void getLinkErrorTest() {
        Test.setMock(HttpCalloutMock.class, new DropBoxConnectionTestMock());
        try {
            Test.startTest();
            new DropBoxConnection().getDownloadLink('Documentdocx');
            Test.stopTest();
        } catch (DropBoxConnection.DropBoxConnectionException e) {
            System.assertEquals(e.getMessage(), e.getMessage());
        }
    }
}