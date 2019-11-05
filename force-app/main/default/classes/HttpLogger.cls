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
        Http_Event__e httpEvent = new Http_Event__e(
                Request_Body__c = request.getBody(),
                Request_Header__c = JSON.serialize(getRequestHeader(request)),
                Response_Body__c = response.getBody(),
                Response_Header__c = JSON.serialize(getResponseHeader(response)),
                Status_Code__c = response.getStatusCode(),
                Url__c = request.getEndpoint()
        );

        publishEvent(httpEvent);
    }

    @TestVisible
    private Map<String, String> getResponseHeader(HttpResponse response) {
        Map<String, String> header = new Map<String, String>();
        if (response != null) {
            for (String key : response.getHeaderKeys()) {
                header.put(key, response.getHeader(key));
            }
        }
        return header;
    }

    @TestVisible
    private Map<String, String> getRequestHeader(HttpRequest request) {
        Map<String, String> header = new Map<String, String>();
        if (request != null) {
            header.put('Content-Type', request.getHeader('Content-Type'));
        }
        return header;
    }

    private void publishEvent(Http_Event__e httpEvent) {
        EventBus.publish(httpEvent);
    }
}