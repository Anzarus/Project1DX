/**
 * Created by AntonAntoniuk on 04.09.2019.
 */

@IsTest
private class TestOppTableController {

    @IsTest
    static void testGettingProduct2sFromOpp() {
        List<Product2> product2s = TestProductAndOppCreator.generateAndConnectProdToOpp(1, 10, 100, 500);

        Opportunity opportunity = [
                SELECT Id
                FROM Opportunity
                LIMIT 1
        ];

        System.assertEquals(product2s, OppTableController.getProduct2sOfOpp(opportunity.Id));
    }

    @IsTest
    static void testDeletingProduct2sFromOpp() {
        List<Product2> product2s = TestProductAndOppCreator.generateAndConnectProdToOpp(1, 10, 100, 500);

        Map<Id, Product2> product2sByIds = new Map<Id, Product2>(product2s);

        Opportunity opportunity = [
                SELECT Id
                FROM Opportunity
                LIMIT 1
        ];

        OppTableController.deleteProdFromOpp(opportunity.Id, product2s.get(5).Id);

        System.assertEquals([
                SELECT Id
                FROM OpportunityLineItem
                WHERE Product2Id IN :product2sByIds.keySet()
        ], [
                SELECT Id
                FROM OpportunityLineItem
                WHERE OpportunityId = :opportunity.Id
        ]
        );
    }
}