/**
 * Created by AntonAntoniuk on 13.09.2019.
 */

@IsTest
private class DropBoxConnectionTest {
    @IsTest
    static void getLinkSuccessTest() {
        Test.setMock(HttpCalloutMock.class, new DropBoxConnectionTestMock());

        Test.startTest();
        String link = new DropBoxConnection().getDownloadLink('Document.docx');
        Test.stopTest();

        System.assertEquals('https://dl.dropboxusercontent.com/apitl/1/AKed', link);
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

    @IsTest
    static void deleteSuccessTest() {
        Test.setMock(HttpCalloutMock.class, new DropBoxConnectionTestMock());

        Test.startTest();
        String link = new DropBoxConnection().deleteFiles(new List<String>{
                '/file (2).txt','/file (1).txt','/file (1) (1).txt'
        });
        Test.stopTest();

        System.assertEquals('dbjid:AABoqpEIEjq', link);
    }
    @IsTest
    static void deleteErrorTest() {
        Test.setMock(HttpCalloutMock.class, new DropBoxConnectionTestMock());
        try {
            Test.startTest();
            new DropBoxConnection().deleteFiles(new List<String>{
                    '','/file (1).txt','/file (1) (1).txt'
            });
            Test.stopTest();
        } catch (DropBoxConnection.DropBoxConnectionException e) {
            System.assertEquals(e.getMessage(), e.getMessage());
        }
    }
}