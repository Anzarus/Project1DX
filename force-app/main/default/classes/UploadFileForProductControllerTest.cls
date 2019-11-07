/**
 * Created by AntonAntoniuk on 07.11.2019.
 */

@IsTest
private class UploadFileForProductControllerTest {
    @IsTest
    static void testGetPersonalFilesForCurrentUser() {
        User testUser = getTestUser();
        ContentVersion content;
        List<ContentDocument> expectedDocuments;
        List<ContentDocument> resultDocuments;
        System.runAs(testUser) {
            content = new ContentVersion(
                    Title = 'Test',
                    PathOnClient = 'Test.jpg',
                    VersionData = Blob.valueOf('Test Content Data'),
                    IsMajorVersion = true
            );
            insert content;

            expectedDocuments = [SELECT Id, Title, FileExtension FROM ContentDocument];
            resultDocuments = UploadFileForProductController.getPersonalFilesForCurrentUser(testUser.Id);
        }
        System.assertEquals(expectedDocuments, resultDocuments);
    }

    @IsTest
    static void testSendFileToDropBox() {
        Product2 product = new Product2(Name = 'TestProduct', Price__c = 1);
        insert product;

        DropBoxConnectionImpl connection =
                (DropBoxConnectionImpl) Test.createStub(DropBoxConnectionImpl.class, new MockProvider());
        UploadFileForProductController.dropBoxUploadable = new DropBoxConnectionUploadableImpl(connection);

        UploadFileForProductController.sendFileToDropBox('Document.docx', Blob.valueOf('content'), product.Id);

        System.assertEquals('/Document.docx', [SELECT File_Id__c FROM Product2 WHERE Id = :product.Id].get(0).File_Id__c);
    }

    @IsTest
    static void testSendFileToDropBoxViaOrg() {
        Product2 product = new Product2(Name = 'TestProduct', Price__c = 1);
        insert product;

        DropBoxConnectionImpl connection =
                (DropBoxConnectionImpl) Test.createStub(DropBoxConnectionImpl.class, new MockProvider());
        UploadFileForProductController.dropBoxUploadable = new DropBoxConnectionUploadableImpl(connection);

        Test.startTest();
        List<ContentDocument> documents;
        User testUser = getTestUser();

        System.runAs(testUser) {
            ContentVersion content = new ContentVersion(
                    Title = 'Document',
                    PathOnClient = 'Document.docx',
                    VersionData = Blob.valueOf('content'),
                    IsMajorVersion = true
            );
            insert content;

            documents = [
                    SELECT Id, Title
                    FROM ContentDocument
                    WHERE LatestPublishedVersionId = :content.Id
            ];
            System.debug(content.VersionData);
            System.debug(EncodingUtil.base64Encode(content.VersionData));
            System.debug(EncodingUtil.base64Encode(Blob.valueOf('content')));

        }


        UploadFileForProductController.sendFileToDropBoxViaOrg(documents[0].Id, product.Id, false);
        Test.stopTest();

        System.assertEquals(new List<ContentDocument>(), [SELECT Id FROM ContentDocument WHERE Id = :documents[0].Id]);
        System.assertEquals('/Document.docx', [SELECT File_Id__c FROM Product2 WHERE Id = :product.Id].get(0).File_Id__c);
    }

    private static User getTestUser() {
        Profile profile = [SELECT Id FROM Profile WHERE Name = 'Standard user' LIMIT 1];
        User testUser = new User(LastName = 'Robinson', Alias = 'Robi', Email = 'antonantonuk1999@gmail.com',
                Username = 'testUserProject1@gmail.com' + Datetime.now().getTime(), CommunityNickname = 'testUser',
                EmailEncodingKey = 'UTF-8', LanguageLocaleKey = 'en_US', LocaleSidKey = 'en_US', ProfileId = profile.Id,
                TimeZoneSidKey = 'America/Los_Angeles');
        return testUser;
    }
}