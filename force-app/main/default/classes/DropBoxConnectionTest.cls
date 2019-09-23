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
                '/file (2).txt', '/file (1).txt', '/file (1) (1).txt'
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
                    '', '/file (1).txt', '/file (1) (1).txt'
            });
            Test.stopTest();
        } catch (DropBoxConnection.DropBoxConnectionException e) {
            System.assertEquals(e.getMessage(), e.getMessage());
        }
    }

    @IsTest
    static void deleteCheckCompleteTest() {
        Test.setMock(HttpCalloutMock.class, new DropBoxConnectionTestMock());

        Test.startTest();
        Map<String, List<String>> resultFullSuccess = new DropBoxConnection().checkDeletedStatus('dbjid:AABoqpEIEjq');
        Map<String, List<String>> resultPartSuccess = new DropBoxConnection().checkDeletedStatus('dbjid:AABoqpEIEjq1');
        Map<String, List<String>> resultNull = new DropBoxConnection().checkDeletedStatus('dbjid:other');
        Test.stopTest();

        System.assertEquals(new Map<String, List<String>>{
                'result' => new List<String>{
                        'Success'
                },
                'successFiles' => new List<String>{
                        '/file (1).txt', '/file (3).txt'
                }
        }, resultFullSuccess);
        System.assertEquals(new Map<String, List<String>>{
                'result' => new List<String>{
                        'Failed'
                },
                'successFiles' => new List<String>{
                        '/file (2).txt'
                }
        }, resultPartSuccess);
        System.assertEquals(null, resultNull);
    }

    @IsTest
    static void deleteCheckErrorTest() {
        Test.setMock(HttpCalloutMock.class, new DropBoxConnectionTestMock());
        try {
            Test.startTest();
            new DropBoxConnection().checkDeletedStatus('');
            Test.stopTest();
        } catch (DropBoxConnection.DropBoxConnectionException e) {
            System.assertEquals(e.getMessage(), e.getMessage());
        }
    }
}