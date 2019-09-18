/**
 * Created by AntonAntoniuk on 12.09.2019.
 */

@IsTest
private class Product2FileFromDropBoxControllerTest {

    @IsTest
    static void product2FileFromDropBoxControllerSuccessWithSavingLinkTest() {
        List<Product2> product2s = new List<Product2>{
                new Product2(Name = 'prod1', File_Id__c = '/Document.docx', Price__c = 10),
                new Product2(Name = 'prod2', File_Id__c = '/Test1.1.odt', Price__c = 10)
        };
        insert product2s;
        Product2Cache__c cacheSetting = new Product2Cache__c(Name = 'Product2FileUrl', isCacheTemporraryLink__c = true);
        insert cacheSetting;

        Test.startTest();

        DropBoxConnection dropBox = (DropBoxConnection) Test.createStub(DropBoxConnection.class, new MockProvider());
        CacheController cache = (CacheController) Test.createStub(CacheController.class, new MockProvider());
        DropBoxFileLinkFabric.dropBox = dropBox;
        DropBoxFileLinkFabric.cacheController = cache;

        String linkSecondTime1 = Product2FileFromDropBoxController.getFileForThisRecord(product2s[0].Id);
        String linkFirstTime2 = Product2FileFromDropBoxController.getFileForThisRecord(product2s[1].Id);

        Test.stopTest();

        System.assertEquals('https://dl.dropboxusercontent.com/apitl/1/Doc', linkSecondTime1);
        System.assertEquals('https://dl.dropboxusercontent.com/apitl/1/Odt', linkFirstTime2);
    }

    @IsTest
    static void product2FileFromDropBoxControllerSuccessWithoutSavingLinkTest() {
        Product2 product2 = new Product2(Name = 'prod1', File_Id__c = '/Document.docx', Price__c = 10);
        insert product2;
        Product2Cache__c cacheSetting = new Product2Cache__c(Name = 'Product2FileUrl', isCacheTemporraryLink__c = false);
        insert cacheSetting;

        Test.startTest();

        DropBoxConnection dropBox = (DropBoxConnection) Test.createStub(DropBoxConnection.class, new MockProvider());
        CacheController cache = (CacheController) Test.createStub(CacheController.class, new MockProvider());
        DropBoxFileLinkFabric.dropBox = dropBox;
        DropBoxFileLinkFabric.cacheController = cache;

        String linkSecondTime1 = Product2FileFromDropBoxController.getFileForThisRecord(product2.Id);

        Test.stopTest();

        System.assertEquals('https://dl.dropboxusercontent.com/apitl/1/Doc', linkSecondTime1);
    }

    @IsTest
    static void product2FileFromDropBoxControllerDropBoxExceptionTest() {
        Product2 product2 = new Product2(Name = 'prod1', File_Id__c = '?GNDFKLM', Price__c = 10);
        insert product2;
        Product2Cache__c cacheSetting = new Product2Cache__c(Name = 'Product2FileUrl', isCacheTemporraryLink__c = true);
        insert cacheSetting;

        try {
            DropBoxConnection dropBox = (DropBoxConnection) Test.createStub(DropBoxConnection.class, new MockProvider());
            CacheController cache = (CacheController) Test.createStub(CacheController.class, new MockProvider());
            DropBoxFileLinkFabric.dropBox = dropBox;
            DropBoxFileLinkFabric.cacheController = cache;

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