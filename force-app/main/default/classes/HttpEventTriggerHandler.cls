/**
 * Created by AntonAntoniuk on 25.09.2019.
 */

public with sharing class HttpEventTriggerHandler {

    public HttpEventTriggerHandler() {
    }

    public void setHttpRecords(List<Http_Event__e> events) {
        List<Http_Life_Cycle__c> httpLifeCycles = new List<Http_Life_Cycle__c>();

        Http_Event__e event;

        for (Integer i = 0; i < events.size(); i++) {
            if (Math.mod(i, 200) == 0) {
                EventBus.TriggerContext.currentContext().setResumeCheckpoint(event.ReplayId);
            }

            event = events[i];

            httpLifeCycles.add(new Http_Life_Cycle__c(
                    Request_Body__c = event.Request_Body__c,
                    Request_Header__c = event.Request_Header__c,
                    Response_Body__c = event.Response_Body__c,
                    Response_Header__c = event.Response_Header__c,
                    Status_Code__c = event.Status_Code__c,
                    Url__c = event.Url__c
            ));
        }
        insert httpLifeCycles;
    }
}