/**
 * Created by AntonAntoniuk on 04.09.2019.
 */

@IsTest
private class TestOppTableController {

    @IsTest
    static void testGettingProduct2sFromOpp() {
        List<Product2> product2s = TestProductAndOppCreator.generateAndConnectProdToOpp(1, 10, 100, 50000);

        Map<Id, Product2> product2sByIds = new Map<Id, Product2>(product2s);

        System.assertEquals([
                SELECT Name, Price__c
                FROM Product2
                WHERE Id IN :product2sByIds.keySet()
        ], product2s);
    }

    @IsTest
    static void testDeletingProduct2sFromOpp() {
        List<Product2> product2s = TestProductAndOppCreator.generateAndConnectProdToOpp(1, 10, 100, 50000);

        Map<Id, Product2> product2sByIds = new Map<Id, Product2>(product2s);

        List<OpportunityLineItem> opportunityLineItems = [
                SELECT Product2Id
                FROM OpportunityLineItem
                WHERE Product2Id IN :product2sByIds.keySet()
        ];

        delete opportunityLineItems;

        List<OpportunityLineItem> opportunityLineItems2 = new List<OpportunityLineItem>();

        System.assertEquals([
                SELECT Id
                FROM OpportunityLineItem
                WHERE Product2Id IN :product2sByIds.keySet()
        ], opportunityLineItems2);
    }
}