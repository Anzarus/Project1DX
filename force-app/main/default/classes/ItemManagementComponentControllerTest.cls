/**
 * Created by AntonAntoniuk on 28.10.2019.
 */

@IsTest
private class ItemManagementComponentControllerTest {
    @TestSetup
    static void createTestData() {
        UnitOfWork unitOfWork = new UnitOfWork(
                new Set<SObjectType>{
                        Pricebook2.SObjectType,
                        Product2.SObjectType,
                        PricebookEntry.SObjectType
                }
        );

        Id standardPb = Test.getStandardPricebookId();

        Pricebook2 pricebook2 = new Pricebook2(Name = 'Test Pricebook', IsActive = true);
        unitOfWork.addToInsert(pricebook2);

        List<Product2> prods = new List<Product2>();

        for (Integer i = 0; i < 10; i++) {
            Product2 product2 = new Product2(
                    Name = 'Test Product ' + i,
                    Price__c = i + 100
            );
            prods.add(product2);
            unitOfWork.addToInsert(product2);

            PricebookEntry standardPricebookEntry = new PricebookEntry(
                    UnitPrice = product2.Price__c, IsActive = true,
                    Pricebook2Id = standardPb, UseStandardPrice = false
            );
            unitOfWork.addToInsert(standardPricebookEntry, PricebookEntry.Product2Id, product2);
        }
        unitOfWork.commitWork();

        unitOfWork = new UnitOfWork(
                new Set<SObjectType>{
                        PricebookEntry.SObjectType
                }
        );

        for (Product2 product2 : prods) {
            PricebookEntry pbEntry = new PricebookEntry(
                    UnitPrice = product2.Price__c, IsActive = true, UseStandardPrice = false,
                    Pricebook2Id = pricebook2.Id, Product2Id = product2.Id
            );
            unitOfWork.addToInsert(pbEntry);
        }
        unitOfWork.commitWork();
    }

    @IsTest
    static void testBehavior() {
        Pricebook2 pricebook2 = [
                SELECT Id
                FROM Pricebook2
                WHERE Name = 'Test Pricebook'
        ];

        List<Product2> product2s =  ItemManagementComponentController.getProductsByPriceBookEntryId(pricebook2.Id);
        System.assertEquals(10, product2s.size());
    }
}