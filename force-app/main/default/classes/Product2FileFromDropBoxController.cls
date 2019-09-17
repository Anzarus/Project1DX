/**
 * Created by AntonAntoniuk on 11.09.2019.
 */

public with sharing class Product2FileFromDropBoxController {

    @AuraEnabled
    public static String getFileForThisRecord(String recordId) {
        Product2 product2 = [
                SELECT File_Id__c
                FROM Product2
                WHERE Id = :Id.valueOf(recordId)
        ];

        DropBoxFileLinkFabric fabric = new DropBoxFileLinkFabric();

        return fabric.getLinkForRecord(product2.File_Id__c);
    }

    @AuraEnabled
    public static Boolean isProdHasFile(String recordId) {
        Product2 product2 = [
                SELECT File_Id__c
                FROM Product2
                WHERE Id = :Id.valueOf(recordId)
        ];

        if (product2.File_Id__c == null
                || product2.File_Id__c.trim() == '') {
            return false;
        }
        return true;
    }
}