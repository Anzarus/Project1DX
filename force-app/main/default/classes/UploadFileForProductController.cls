/**
 * Created by AntonAntoniuk on 06.11.2019.
 */

public with sharing class UploadFileForProductController {

    @TestVisible
    private static DropBoxConnectionUploadable dropBoxUploadable = new DropBoxConnectionUploadableImpl(new DropBoxConnectionImpl());

    @AuraEnabled(Cacheable=true)
    public static List<ContentDocument> getPersonalFilesForCurrentUser(Id currentUserId) {
        return [
                SELECT Id, Title, FileExtension
                FROM ContentDocument
                WHERE OwnerId = :currentUserId
        ];
    }

    @AuraEnabled
    public static void sendFileToDropBox(String fileId, Blob content, String productId) {
        String resultPath = dropBoxUploadable.uploadFile(
                '/' + fileId, content
        );

        update new Product2(Id = productId, File_Id__c = resultPath);
    }

    @AuraEnabled
    public static void sendFileToDropBoxViaOrg(String fileId, String productId, Boolean cacheToOrg) {
        ContentVersion file = [
                SELECT VersionData, Title, FileExtension
                FROM ContentVersion
                WHERE ContentDocumentId = :fileId AND IsLatest = TRUE
        ];

        System.debug(EncodingUtil.base64Encode(file.VersionData));


        String resultPath = dropBoxUploadable.uploadFile(
                '/' + file.Title + '.' + file.FileExtension, file.VersionData
        );

        update new Product2(Id = productId, File_Id__c = resultPath);

        if (!cacheToOrg) {
            delete new ContentDocument(Id = fileId);
        }
    }
}