/**
 * Created by AntonAntoniuk on 25.09.2019.
 */

@IsTest
private class HttpEventTriggerHandlerTest {
    @IsTest
    static void testBehavior() {
        List<Http_Event__e> events = new List<Http_Event__e>();

        for (Integer i = 0; i < 400; i++) {
            events.add(new Http_Event__e(
                    Request_Body__c = 'Request_Body__c' + i,
                    Request_Header__c = 'Request_Header__c' + i,
                    Response_Body__c = 'Response_Body__c' + i,
                    Response_Header__c = 'Response_Header__c' + i,
                    Status_Code__c = i,
                    Url__c = 'Url__c' + i
            ));
        }

        Test.startTest();
        List<Database.SaveResult> results = EventBus.publish(events);
        Test.stopTest();

        List<Http_Life_Cycle__c> httpLifeCycles = [
                SELECT
                        Request_Body__c, Request_Header__c, Response_Body__c,
                        Response_Header__c, Status_Code__c, Url__c
                FROM Http_Life_Cycle__c
        ];

        System.assertEquals(httpLifeCycles.size(), 400);
        for (Integer i = 0; i < 400; i++) {
            System.assert(results[i].isSuccess());
        }
    }
}