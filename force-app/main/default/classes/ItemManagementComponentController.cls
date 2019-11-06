/**
 * Created by AntonAntoniuk on 20.10.2019.
 */

public with sharing class ItemManagementComponentController {

    @AuraEnabled(Cacheable=true)
    public static List<Product2> getProductsByPriceBookEntryId(String recordId) {
        return [
                SELECT Name, Price__c, Status__c, ProductCode, Family, File_Id__c
                FROM Product2
                WHERE Id IN (
                        SELECT Product2Id
                        FROM PricebookEntry
                        WHERE Pricebook2Id = :Id.valueOf(recordId)
                )
                ORDER BY Name ASC
        ];
    }
}