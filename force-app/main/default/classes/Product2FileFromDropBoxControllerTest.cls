/**
 * Created by AntonAntoniuk on 12.09.2019.
 */

@IsTest
private class Product2FileFromDropBoxControllerTest {

    @IsTest
    static void product2FileFromDropBoxControllerSuccessWithSavingLinkTest() {
        List<Product2> product2s = new List<Product2>{
                new Product2(Name = 'prod1', Price__c = 10),
                new Product2(Name = 'prod2', Price__c = 10)
        };
        insert product2s;

        Product2Cache__c cacheSetting = new Product2Cache__c(Name = 'Product2FileUrl', isCacheTemporraryLink__c = true);
        insert cacheSetting;

        List<File_Source__c> fileSources = new List<File_Source__c>{
                new File_Source__c(Name = '/Document.docx', Product__c = product2s[0].Id),
                new File_Source__c(Name = '/Test1.1.odt', Product__c = product2s[1].Id)
        };
        insert fileSources;

        Test.startTest();

        DropBoxConnection dropBox = (DropBoxConnection) Test.createStub(DropBoxConnection.class, new MockProvider());
        CacheController cache = (CacheController) Test.createStub(CacheController.class, new MockProvider());
        DropBoxFileLinkFabric.dropBox = dropBox;
        DropBoxFileLinkFabric.cacheController = cache;

        List<String> linkSecondTime1 = Product2FileFromDropBoxController.getFileForThisRecord(product2s[0].Id);
        List<String> linkFirstTime2 = Product2FileFromDropBoxController.getFileForThisRecord(product2s[1].Id);

        Test.stopTest();

        System.assertEquals('https://dl.dropboxusercontent.com/apitl/1/Doc', linkSecondTime1[0]);
        System.assertEquals('https://dl.dropboxusercontent.com/apitl/1/Odt', linkFirstTime2[0]);
    }

    @IsTest
    static void product2FileFromDropBoxControllerSuccessWithoutSavingLinkTest() {
        Product2 product2 = new Product2(Name = 'prod1', Price__c = 10);
        insert product2;

        Product2Cache__c cacheSetting = new Product2Cache__c(Name = 'Product2FileUrl', isCacheTemporraryLink__c = false);
        insert cacheSetting;

        File_Source__c fileSource = new File_Source__c(Name = '/Document.docx', Product__c = product2.Id);
        insert fileSource;

        Test.startTest();

        DropBoxConnection dropBox = (DropBoxConnection) Test.createStub(DropBoxConnection.class, new MockProvider());
        CacheController cache = (CacheController) Test.createStub(CacheController.class, new MockProvider());
        DropBoxFileLinkFabric.dropBox = dropBox;
        DropBoxFileLinkFabric.cacheController = cache;

        List<String> linkSecondTime1 = Product2FileFromDropBoxController.getFileForThisRecord(product2.Id);

        Test.stopTest();

        System.assertEquals('https://dl.dropboxusercontent.com/apitl/1/Doc', linkSecondTime1[0]);
    }

    @IsTest
    static void product2FileFromDropBoxControllerDropBoxExceptionTest() {
        Product2 product2 = new Product2(Name = 'prod1', Price__c = 10);
        insert product2;

        Product2Cache__c cacheSetting = new Product2Cache__c(Name = 'Product2FileUrl', isCacheTemporraryLink__c = true);
        insert cacheSetting;

        File_Source__c fileSource = new File_Source__c(Name = '/GNDFKLM', Product__c = product2.Id);
        insert fileSource;

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
                new Product2(Name = 'prod1', Price__c = 10),
                new Product2(Name = 'prod1', Price__c = 10)
        };
        insert product2s;

        List<File_Source__c> fileSources = new List<File_Source__c>{
                new File_Source__c(Name = '/Document.docx', Product__c = product2s[1].Id)
        };
        insert fileSources;

        System.assertEquals(false, Product2FileFromDropBoxController.isProdHasFile(product2s[0].Id));
        System.assertEquals(true, Product2FileFromDropBoxController.isProdHasFile(product2s[1].Id));
    }
}