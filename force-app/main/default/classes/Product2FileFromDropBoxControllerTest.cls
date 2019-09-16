/**
 * Created by AntonAntoniuk on 12.09.2019.
 */

@IsTest
private class Product2FileFromDropBoxControllerTest {

    @IsTest
    static void product2FileFromDropBoxControllerSuccessTest() {
        List<Product2> product2s = new List<Product2>{
                new Product2(Name = 'prod1', File_Id__c = '/Document.docx', Price__c = 10),
                new Product2(Name = 'prod2', File_Id__c = '/Test1.1.odt', Price__c = 10)
        };
        insert product2s;

        Test.startTest();
        DropBoxConnection dropBox = (DropBoxConnection) Test.createStub(DropBoxConnection.class, new MockProvider());
//        Product2FileFromDropBoxController.dropBox = dropBox;
        String link1 = Product2FileFromDropBoxController.getFileForThisRecord(product2s[0].Id);
        String link2 = Product2FileFromDropBoxController.getFileForThisRecord(product2s[1].Id);
        Test.stopTest();

        System.assertEquals('https://dl.dropboxusercontent.com/apitl/1/Doc', link1);
        System.assertEquals('https://dl.dropboxusercontent.com/apitl/1/Odt', link2);
    }

    @IsTest
    static void product2FileFromDropBoxControllerDropBoxExceptionTest() {
        Product2 product2 = new Product2(Name = 'prod1', File_Id__c = ' ', Price__c = 10);
        insert product2;

        try {
            DropBoxConnection dropBox = (DropBoxConnection) Test.createStub(DropBoxConnection.class, new MockProvider());
//            Product2FileFromDropBoxController.dropBox = dropBox;
            Product2FileFromDropBoxController.getFileForThisRecord(product2.Id);
        } catch (DropBoxConnection.DropBoxConnectionException e) {
            System.assertEquals(e.getMessage(), e.getMessage());
        }
    }

    @IsTest
    static void product2FileFromDropBoxControllerDropBoxHasFileTest() {
        List<Product2> product2s = new List<Product2>{
                new Product2(Name = 'prod1', File_Id__c = '', Price__c = 10),
                new Product2(Name = 'prod1', File_Id__c = '/Document.docx', Price__c = 10)
        };
        insert product2s;

        System.assertEquals(false, Product2FileFromDropBoxController.isProdHasFile(product2s[0].Id));
        System.assertEquals(true, Product2FileFromDropBoxController.isProdHasFile(product2s[1].Id));
    }
}