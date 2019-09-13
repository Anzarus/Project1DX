/**
 * Created by AntonAntoniuk on 11.09.2019.
 */

public with sharing class Product2FileFromDropBoxController {

    private static DropBoxConnection dropBox = new DropBoxConnection();

    @AuraEnabled
    public static String getFileForThisRecord(String recordId) {
        try {
            Product2 product2 = [
                    SELECT File_Id__c
                    FROM Product2
                    WHERE Id = :Id.valueOf(recordId)
            ];

            return dropBox.getDownloadLink(product2.File_Id__c);
        } catch (AuraHandledException e) {
            throw e;
        }
    }

    @AuraEnabled
    public static Boolean isProdHasFile(String recordId) {
        Product2 product2 = [
                SELECT File_Id__c
                FROM Product2
                WHERE Id = :Id.valueOf(recordId)
        ];

        if (product2.File_Id__c == null) {
            return false;
        }
        return true;
    }
}