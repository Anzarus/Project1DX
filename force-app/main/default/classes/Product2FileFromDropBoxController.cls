/**
 * Created by AntonAntoniuk on 11.09.2019.
 */

public with sharing class Product2FileFromDropBoxController {

    @AuraEnabled
    public static List<String> getFileForThisRecord(String recordId) {
        List<File_Source__c> fileSources = [
                SELECT Name
                FROM File_Source__c
                WHERE Product__c = :Id.valueOf(recordId)
        ];

        DropBoxFileLinkFabric fabric = new DropBoxFileLinkFabric();

        List<String> fileUrls = new List<String>();
        for (File_Source__c file : fileSources) {
            fileUrls.add(fabric.getLinkForRecord(file.Name));
        }
        return fileUrls;
    }

    @AuraEnabled
    public static Boolean isProdHasFile(String recordId) {
        List<File_Source__c> fileSources = [
                SELECT Name
                FROM File_Source__c
                WHERE Product__c = :Id.valueOf(recordId)
        ];

        if (fileSources.isEmpty()) {
            return false;
        }
        return true;
    }
}