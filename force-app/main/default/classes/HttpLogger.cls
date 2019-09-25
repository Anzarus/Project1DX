/**
 * Created by AntonAntoniuk on 25.09.2019.
 */

public with sharing class HttpLogger {

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

        EventBus.publish(httpEvent);
    }
}