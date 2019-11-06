/**
 * Created by AntonAntoniuk on 06.11.2019.
 */

public with sharing class UploadFileForProductController {

    @AuraEnabled(Cacheable=true)
    public static List<ContentDocument> getPersonalFilesForCurrentUser(Id currentUserId) {
        return [
                SELECT Id, Title, FileExtension
                FROM ContentDocument
                WHERE OwnerId = :currentUserId
        ];
    }

    @AuraEnabled
    public static void sendFileToDropBox(String fileId, String productId, Boolean cacheToOrg) {
        System.debug(fileId);

        ContentVersion file = [
                SELECT VersionData, Title, FileExtension
                FROM ContentVersion
                WHERE ContentDocumentId = :fileId AND IsLatest = TRUE
        ];

        System.debug(file);

        DropBoxConnection dropBox = new DropBoxConnectionImpl();
        DropBoxConnectionUploadable dropBoxUploadable = new DropBoxConnectionUploadableImpl(dropBox);

        String resultPath = dropBoxUploadable.uploadFile(
                '/' + file.Title + '.' + file.FileExtension, file.VersionData
        );

        update new Product2(Id = productId, File_Id__c = resultPath);

        if (!cacheToOrg) {
            delete new ContentDocument(Id = fileId);
        }
    }
}