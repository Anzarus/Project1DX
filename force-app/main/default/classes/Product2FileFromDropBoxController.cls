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

        LinkToFileInDropBoxGetter linkGetter = new LinkToFileInDropBoxGetter(product2.File_Id__c);
        return linkGetter.getDownloadLink();
    }
}