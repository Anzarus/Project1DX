/**
 * Created by AntonAntoniuk on 20.10.2019.
 */

public with sharing class ItemManagementComponentController {

    @AuraEnabled(Cacheable=true)
    public static List<Product2> getItems(String recordId) {
        List<PricebookEntry> pricebookEntries = [
                SELECT Product2Id
                FROM PricebookEntry
                WHERE Pricebook2Id = :Id.valueOf(recordId)
        ];

        Set<Id> pricebookEntriesProdIds = new Set<Id>();
        for (PricebookEntry pricebookEntry : pricebookEntries) {
            pricebookEntriesProdIds.add(pricebookEntry.Product2Id);
        }

        return [
                SELECT Name, Price__c, Status__c, ProductCode, Family, File_Id__c
                FROM Product2
                WHERE Id IN :pricebookEntriesProdIds
        ];
    }
}