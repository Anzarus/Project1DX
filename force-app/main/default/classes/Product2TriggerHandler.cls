/**
 * Created by AntonAntoniuk on 13.08.2019.
 */

public with sharing class Product2TriggerHandler {

    private OpportunityTotalPriceRecalculator recalculator;

    public Product2TriggerHandler() {
    }

    public void onUpdate(List<Product2> newProduct2s, Map<Id, Product2> oldProduct2sByIds) {

        Map<Id, Product2> newProduct2sByIds = checkWhichProdChangePriceAndFormMap(newProduct2s, oldProduct2sByIds);
        Map<Id, Product2> updatedOldProduct2sByIds = getUpdatedOldProduct2sByIds(newProduct2sByIds, oldProduct2sByIds);

        recalculator = new OpportunityTotalPriceRecalculator(newProduct2sByIds, updatedOldProduct2sByIds);

        recalculator.checkLinkToOppAndUpdateOpp();
        recalculator.subProdPriceFromOpp();
    }

    private Map<Id, Product2> checkWhichProdChangePriceAndFormMap(List<Product2> newProduct2s, Map<Id, Product2> oldProduct2sByIds) {
        Map<Id, Product2> newProduct2sByIds = new Map<Id, Product2>();
        for (Product2 prod : newProduct2s) {
            if (prod.Price__c != oldProduct2sByIds.get(prod.Id).Price__c) newProduct2sByIds.put(prod.Id, prod);
        }
        return newProduct2sByIds;
    }

    private Map<Id, Product2> getUpdatedOldProduct2sByIds(Map<Id, Product2> newProduct2sByIds, Map<Id, Product2> oldProduct2sByIds) {
        Map<Id, Product2> updatedOldProduct2sByIds = new Map<Id, Product2>();
        for (Product2 prod : newProduct2sByIds.values()) {
            if (oldProduct2sByIds.containsKey(prod.Id)) updatedOldProduct2sByIds.put(prod.Id, oldProduct2sByIds.get(prod.Id));
        }
        return updatedOldProduct2sByIds;
    }

    public void onDelete(List<Product2> deletedProds) {
        List<String> product2sFileIds = new List<String>();

        for (Product2 prod : deletedProds) {
            product2sFileIds.add(prod.File_Id__c);
        }
        callDropBoxDeleting(product2sFileIds);
    }

    @Future(Callout=true)
    private static void callDropBoxDeleting(List<String> product2sFileIds) {
        String jobId = new DropBoxConnection().deleteFiles(product2sFileIds);

        Remove_Job__c removeJob = new Remove_Job__c(JobId__c = jobId);
        insert removeJob;
    }
}