/**
 * Created by AntonAntoniuk on 11.09.2019.
 */

public with sharing class Product2FileFromDropBoxController {

    @TestVisible
    static DropBoxFileLinkFabric fabric = new DropBoxFileLinkFabric();

    @AuraEnabled
    public static String getFileForThisRecord(String recordId) {
        Product2 product2 = [
                SELECT File_Id__c
                FROM Product2
                WHERE Id = :Id.valueOf(recordId)
        ];

        DropBoxConnection connector = fabric.getDropBoxConnector();
        return connector.getDownloadLink(product2.File_Id__c);
    }

    @AuraEnabled
    public static Boolean isProdHasFile(String recordId) {
        Product2 product2 = [
                SELECT File_Id__c
                FROM Product2
                WHERE Id = :Id.valueOf(recordId)
        ];

        if (String.isEmpty(product2.File_Id__c)) {
            return false;
        }
        return true;
    }
}