/**
 * Created by AntonAntoniuk on 06.11.2019.
 */

public with sharing class UploadFileForProductController {

    @AuraEnabled(Cacheable=true)
    public static List<ContentDocument> getPersonalFilesForCurrentUser(Id currentUserId) {
        return [
                SELECT Title, FileExtension
                FROM ContentDocument
                WHERE OwnerId = :currentUserId
        ];
    }

    @AuraEnabled
    public static void sendFileToDropBox(Id fileId) {
System.debug(fileId);
    }
}