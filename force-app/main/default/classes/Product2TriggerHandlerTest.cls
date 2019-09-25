/**
 * Created by AntonAntoniuk on 14.08.2019.
 */

@IsTest
private class Product2TriggerHandlerTest {

    final static Integer LOW_BORDER_PRICE = 100;
    final static Integer HIGH_BORDER_PRICE = 10000;

    @IsTest
    static void testOneProductToOneOppPriceUpdate() {
        List<Product2> product2s = TestProductAndOppCreator.generateAndConnectProdToOpp(1, 1,
                LOW_BORDER_PRICE, HIGH_BORDER_PRICE);
        Map<Id, Product2> product2sByIds = new Map<Id, Product2>(product2s);

        Test.startTest();

        List<OpportunityLineItem> oppLineItems = getOppLineItems(product2sByIds);
        Map<Id, OpportunityLineItem> oppLineItemsByOppIds = getOppLineItemsByOppIds(oppLineItems);

        List<Opportunity> opps = getOpps(oppLineItemsByOppIds);

        Map<Id, Double> differenceOfPrices;

        User testUser = getTestUser();
        System.runAs(testUser) {
            differenceOfPrices = getDifferenceOfPrices(product2s, product2s.size());
        }

        List<Opportunity> updatedOpps = getOpps(oppLineItemsByOppIds);

        Test.stopTest();

        System.assertEquals(opps[0].Total_Price__c + differenceOfPrices.get(product2s[0].Id) *
                oppLineItemsByOppIds.get(updatedOpps[0].Id).Quantity, updatedOpps[0].Total_Price__c);
    }

    @IsTest
    static void testOneProductToManyOppPriceUpdate() {
        List<Product2> product2s = TestProductAndOppCreator.generateAndConnectProdToOpp(200, 1,
                LOW_BORDER_PRICE, HIGH_BORDER_PRICE);
        Map<Id, Product2> product2sByIds = new Map<Id, Product2>(product2s);

        Test.startTest();

        List<OpportunityLineItem> oppLineItems = getOppLineItems(product2sByIds);
        Map<Id, OpportunityLineItem> oppLineItemsByOppIds = getOppLineItemsByOppIds(oppLineItems);

        List<Opportunity> opps = getOpps(oppLineItemsByOppIds);

        Map<Id, Double> differenceOfPrices;

        User testUser = getTestUser();
        System.runAs(testUser) {
            differenceOfPrices = getDifferenceOfPrices(product2s, product2s.size());
        }

        List<Opportunity> updatedOpps = getOpps(oppLineItemsByOppIds);

        Test.stopTest();

        for (Integer i = 0; i < opps.size(); i++) {
            System.assertEquals(opps[i].Total_Price__c + differenceOfPrices.get(product2s[0].Id) *
                    oppLineItemsByOppIds.get(updatedOpps[i].Id).Quantity, updatedOpps[i].Total_Price__c);
        }
    }

    @IsTest
    static void testManyProductToOneOppPriceUpdate() {
        List<Product2> product2s = TestProductAndOppCreator.generateAndConnectProdToOpp(1, 200,
                LOW_BORDER_PRICE, HIGH_BORDER_PRICE);
        Map<Id, Product2> product2sByIds = new Map<Id, Product2>(product2s);

        Test.startTest();

        List<OpportunityLineItem> oppLineItems = getOppLineItems(product2sByIds);
        Map<Id, OpportunityLineItem> oppLineItemsByOppIds = getOppLineItemsByOppIds(oppLineItems);

        List<Opportunity> opps = getOpps(oppLineItemsByOppIds);

        Map<Id, Double> differenceOfPrices;

        User testUser = getTestUser();
        System.runAs(testUser) {
            differenceOfPrices = getDifferenceOfPrices(product2s, product2s.size());
        }

        List<Opportunity> updatedOpps = getOpps(oppLineItemsByOppIds);

        Test.stopTest();

        Map<Id, OpportunityLineItem> oppLineItemsByProdIds = getOppLineItemsByProdIds(oppLineItems);

        for (Integer i = 0; i < product2s.size(); i++) {
            opps[0].Total_Price__c += differenceOfPrices.get(product2s[i].Id) *
                    oppLineItemsByProdIds.get(product2s[i].Id).Quantity;
        }
        System.assertEquals(opps[0].Total_Price__c, updatedOpps[0].Total_Price__c);
    }

    @IsTest
    static void testManyProductToManyOppPriceUpdate() {
        List<Product2> product2s = TestProductAndOppCreator.generateAndConnectProdToOpp(20, 10,
                LOW_BORDER_PRICE, HIGH_BORDER_PRICE);
        Map<Id, Product2> product2sByIds = new Map<Id, Product2>(product2s);

        Test.startTest();

        List<OpportunityLineItem> oppLineItems = getOppLineItems(product2sByIds);
        Map<Id, OpportunityLineItem> oppLineItemsByOppIds = getOppLineItemsByOppIds(oppLineItems);

        List<Opportunity> opps = getOpps(oppLineItemsByOppIds);

        Map<Id, Double> differenceOfPrices;

        User testUser = getTestUser();
        System.runAs(testUser) {
            differenceOfPrices = getDifferenceOfPrices(product2s, product2s.size());
        }

        List<Opportunity> updatedOpps = getOpps(oppLineItemsByOppIds);

        Test.stopTest();

        for (Integer i = 0; i < opps.size(); i++) {
            for (Integer j = 0; j < product2s.size(); j++) {
                opps[i].Total_Price__c += differenceOfPrices.get(product2s[j].Id) *
                        getTargetQuantity(oppLineItems, opps[i], product2s[j]);
            }
            System.assertEquals(opps[i].Total_Price__c, updatedOpps[i].Total_Price__c);
        }
    }

    @IsTest
    static void testProductUpdatePrice() {
        List<Product2> product2s = TestProductAndOppCreator.generateAndConnectProdToOpp(1, 1000,
                LOW_BORDER_PRICE, HIGH_BORDER_PRICE);
        Map<Id, Product2> product2sByIds = new Map<Id, Product2>(product2s);

        Test.startTest();

        List<OpportunityLineItem> oppLineItems = getOppLineItems(product2sByIds);
        Map<Id, OpportunityLineItem> oppLineItemsByOppIds = getOppLineItemsByOppIds(oppLineItems);

        List<Opportunity> opps = getOpps(oppLineItemsByOppIds);

        Map<Id, Double> differenceOfPrices;
        Integer quantityOfProduct2sUpdatedByPrice;

        User testUser = getTestUser();
        System.runAs(testUser) {
            quantityOfProduct2sUpdatedByPrice = Integer.valueOf(Math.random() * product2s.size());
            renamePartOfProducts(product2s, quantityOfProduct2sUpdatedByPrice);

            differenceOfPrices = getDifferenceOfPrices(product2s, quantityOfProduct2sUpdatedByPrice);
        }

        List<Opportunity> updatedOpps = getOpps(oppLineItemsByOppIds);

        Test.stopTest();

        Map<Id, OpportunityLineItem> oppLineItemsByProdIds = getOppLineItemsByProdIds(oppLineItems);

        for (Integer i = 0; i < quantityOfProduct2sUpdatedByPrice; i++) {
            opps[0].Total_Price__c += differenceOfPrices.get(product2s[i].Id) *
                    oppLineItemsByProdIds.get(product2s[i].Id).Quantity;
        }
        System.assertEquals(opps[0].Total_Price__c, updatedOpps[0].Total_Price__c);
    }

    @IsTest
    static void testSuccessDeleting() {
        Test.setMock(HttpCalloutMock.class, new DropBoxConnectionTestMock());

        List<Product2> prods = new List<Product2>{
                new Product2(Name = 'prod1', Price__c = 1),
                new Product2(Name = 'prod2', Price__c = 1),
                new Product2(Name = 'prod3', Price__c = 1)
        };
        insert prods;

        List<File_Source__c> files = new List<File_Source__c>{
                new File_Source__c(Name = '/file (2).txt', Product__c = prods[0].Id),
                new File_Source__c(Name = '/file (1).txt', Product__c = prods[1].Id),
                new File_Source__c(Name = '/file (1) (1).txt', Product__c = prods[2].Id)
        };
        insert files;

        Test.startTest();
        delete prods;
        Test.stopTest();

        System.assertEquals(new List<Product2>(), [
                SELECT Id
                FROM Product2
        ]);
    }

    private static User getTestUser() {
        Profile profile = [SELECT Id FROM Profile WHERE Name = 'Standard user' LIMIT 1];
        User testUser = new User(LastName = 'Robinson', Alias = 'Robi', Email = 'antonantonuk1999@gmail.com',
                Username = 'testUserProject1@gmail.com' + Datetime.now().getTime(), CommunityNickname = 'testUser',
                EmailEncodingKey = 'UTF-8', LanguageLocaleKey = 'en_US', LocaleSidKey = 'en_US', ProfileId = profile.Id,
                TimeZoneSidKey = 'America/Los_Angeles');

        PermissionSet permissionSet = [SELECT Id FROM PermissionSet WHERE Label = 'Project 1 user permission set'];
        PermissionSetAssignment psa = new PermissionSetAssignment
                (PermissionSetId = permissionSet.Id, AssigneeId = testUser.Id);

        return testUser;
    }

    private static Map<Id, OpportunityLineItem> getOppLineItemsByOppIds(List<OpportunityLineItem> oppLineItems) {
        Map<Id, OpportunityLineItem> oppLineItemsByOppIds = new Map<Id, OpportunityLineItem>();
        for (OpportunityLineItem oppLineItem : oppLineItems) {
            if (!oppLineItemsByOppIds.containsKey(oppLineItem.Id)) {
                oppLineItemsByOppIds.put(oppLineItem.OpportunityId, oppLineItem);
            }
        }
        return oppLineItemsByOppIds;
    }

    private static Map<Id, OpportunityLineItem> getOppLineItemsByProdIds(List<OpportunityLineItem> oppLineItems) {
        Map<Id, OpportunityLineItem> oppLineItemsByProdIds = new Map<Id, OpportunityLineItem>();
        for (OpportunityLineItem oppLineItem : oppLineItems) {
            if (!oppLineItemsByProdIds.containsKey(oppLineItem.Product2Id)) {
                oppLineItemsByProdIds.put(oppLineItem.Product2Id, oppLineItem);
            }
        }
        return oppLineItemsByProdIds;
    }

    private static List<OpportunityLineItem> getOppLineItems(Map<Id, Product2> product2sByIds) {
        List<OpportunityLineItem> oppLineItems = [
                SELECT Id, OpportunityId, Product2Id, Quantity
                FROM OpportunityLineItem
                WHERE Product2Id IN :product2sByIds.keySet()
        ];
        return oppLineItems;
    }

    private static List<Opportunity> getOpps(Map<Id, OpportunityLineItem> oppLineItemsByOppIds) {
        List<Opportunity> opps = [
                SELECT Id, Total_Price__c
                FROM Opportunity
                WHERE Id IN :oppLineItemsByOppIds.keySet()
        ];
        return opps;
    }

    private static Map<Id, Double> getDifferenceOfPrices(List<Product2> product2s, Integer quantityToUpdate) {
        Map<Id, Double> differenceOfPrices = new Map<Id, Double>();
        Double diff;
        Double unitPrice;
        for (Integer i = 0; i < quantityToUpdate; i++) {
            unitPrice = product2s[i].Price__c - 1;
            diff = Decimal.valueOf(1000 * Math.random() - unitPrice);
            product2s[i].Price__c += diff;
            differenceOfPrices.put(product2s[i].Id, diff);
        }
        update product2s;
        return differenceOfPrices;
    }

    private static void renamePartOfProducts(List<Product2> originalProduct2s, Integer quantityOfProduct2sUpdatedByPrice) {
        for (Integer i = quantityOfProduct2sUpdatedByPrice; i < originalProduct2s.size(); i++) {
            originalProduct2s[i].Name = 'New Product Name ' + i;
        }
    }

    private static Decimal getTargetQuantity(List<OpportunityLineItem> oppLineItems, Opportunity opp, Product2 prod) {
        Decimal targetQuantity;
        for (Integer i = 0; i < oppLineItems.size(); i++) {
            if (oppLineItems[i].Product2Id == prod.Id && oppLineItems[i].OpportunityId == opp.Id) {
                targetQuantity = oppLineItems[i].Quantity;
                break;
            }
        }
        return targetQuantity;
    }

    private class DropBoxConnectionTestMock implements HttpCalloutMock {

        public HttpResponse respond(HttpRequest request) {
            HttpResponse response = new HttpResponse();
            if (request.getEndpoint() == 'callout:DropBoxGetFile/delete_batch') {
                if (request.getBody() == '{\"entries\": [{\"path\": \"/file (2).txt\"}, ' +
                        '{\"path\": \"/file (1).txt\"}, ' +
                        '{\"path\": \"/file (1) (1).txt\"}]}') {
                    response.setStatusCode(200);
                    response.setBody('{".tag": "async_job_id", "async_job_id": "dbjid:AABoqpEIEjq"}');
                } else {
                    response.setStatusCode(409);
                    response.setBody('Something went wrong!');
                }
            }
            return response;
        }
    }
}