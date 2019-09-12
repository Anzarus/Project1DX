/**
 * Created by AntonAntoniuk on 11.09.2019.
 */
@IsTest
public with sharing class LinkToFileInDropBoxGetterTest {
    @IsTest
    static void getLinkSuccessTest() {
        Test.setMock(HttpCalloutMock.class, new LinkToFileInDropBoxGetterTestMock());
        LinkToFileInDropBoxGetter linkGetter = new LinkToFileInDropBoxGetter('Document.docx');

        Test.startTest();
        System.assertEquals('https://dl.dropboxusercontent.com/apitl/1/AKed', linkGetter.getDownloadLink());
        Test.stopTest();
    }

    @IsTest
    static void getLinkErrorTest() {
        Test.setMock(HttpCalloutMock.class, new LinkToFileInDropBoxGetterTestMock());
        LinkToFileInDropBoxGetter linkGetter = new LinkToFileInDropBoxGetter('Documentdocx');

        Test.startTest();
        System.assertEquals('Error 409: Something went wrong!', linkGetter.getDownloadLink());
        Test.stopTest();
    }

    @IsTest
    static void product2FileFromDropBoxControllerCorrectTest() {
        Test.setMock(HttpCalloutMock.class, new LinkToFileInDropBoxGetterTestMock());
        Product2 product2 = new Product2(Name = 'prod', File_Id__c = 'Document.docx', Price__c = 10);
        insert product2;

        Test.startTest();
        String link = Product2FileFromDropBoxController.getFileForThisRecord(product2.Id);
        Test.stopTest();

        System.assertEquals('https://dl.dropboxusercontent.com/apitl/1/AKed', link);
    }

    @IsTest
    static void product2FileFromDropBoxControllerErrorTest() {
        Test.setMock(HttpCalloutMock.class, new LinkToFileInDropBoxGetterTestMock());
        Product2 product2 = new Product2(Name = 'prod', File_Id__c = 'Documentdocx', Price__c = 10);
        insert product2;

        Test.startTest();
        String link = Product2FileFromDropBoxController.getFileForThisRecord(product2.Id);
        Test.stopTest();

        System.assertEquals('Error 409: Something went wrong!', link);
    }
}
