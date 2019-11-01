/**
 * Created by AntonAntoniuk on 25.09.2019.
 */

public with sharing class HttpLogger {

    public void logHttpUsingPlatformEvent(Map<String, String> eventValues) {
        Http_Event__e httpEvent = new Http_Event__e(
                Request_Body__c = eventValues.get('RequestBody'),
                Request_Header__c = eventValues.get('RequestHeader'),
                Response_Body__c = eventValues.get('ResponseBody'),
                Response_Header__c = eventValues.get('ResponseHeader'),
                Status_Code__c = Decimal.valueOf(eventValues.get('StatusCode')),
                Url__c = eventValues.get('Url')
        );

        publishEvent(httpEvent);
    }

    public void logHttpUsingPlatformEvent(HttpRequest request, HttpResponse response) {
        List<String> responseHeaderKeys = response.getHeaderKeys();
        List<String> responseHeader = new List<String>();
        for (String str : responseHeaderKeys) {
            responseHeader.add(str);
        }

        Http_Event__e httpEvent = new Http_Event__e(
                Request_Body__c = request.getBody(),
                Request_Header__c = request.getHeader('Content-Type'),
                Response_Body__c = response.getBody(),
                Response_Header__c = String.valueOf(responseHeader),
                Status_Code__c = response.getStatusCode(),
                Url__c = request.getEndpoint()
        );

        publishEvent(httpEvent);
    }

    private void publishEvent(Http_Event__e httpEvent){
        EventBus.publish(httpEvent);
    }
}