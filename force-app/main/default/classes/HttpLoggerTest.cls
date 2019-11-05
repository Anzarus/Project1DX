/**
 * Created by AntonAntoniuk on 25.09.2019.
 */

@IsTest
private class HttpLoggerTest {
    @IsTest
    static void testBehaviorWithMapConstructor() {
        Test.setMock(HttpCalloutMock.class, new DropBoxConnectionTestMock());

        HttpRequest request = new HttpRequest();
        Http http = new Http();

        request.setEndpoint('callout:DropBoxGetFile/get_temporary_link');
        request.setMethod('POST');
        request.setHeader('Content-Type', 'application/json');
        request.setBody('{request body}');
        HttpResponse response = http.send(request);

        Test.startTest();
        HttpLogger httpLogger = new HttpLogger();

        String requestHeader = JSON.serialize(httpLogger.getRequestHeader(request));
        String responseHeader = JSON.serialize(httpLogger.getResponseHeader(response));

        httpLogger.logHttpUsingPlatformEvent(
                new Map<String, String>{
                        'RequestBody' => request.getBody(),
                        'RequestHeader' => requestHeader,
                        'ResponseBody' => response.getBody(),
                        'ResponseHeader' => responseHeader,
                        'StatusCode' => String.valueOf(response.getStatusCode()),
                        'Url' => request.getEndpoint()
                }
        );
        Test.stopTest();

        Http_Life_Cycle__c httpLifeCycle = [
                SELECT Request_Body__c, Request_Header__c,
                        Response_Body__c, Response_Header__c,
                        Status_Code__c, Url__c
                FROM Http_Life_Cycle__c
                LIMIT 1
        ];

        System.assertEquals(httpLifeCycle.Request_Body__c, request.getBody());
        System.assertEquals(httpLifeCycle.Request_Header__c, JSON.serialize(new Map<String, String>{
                'Content-Type' => request.getHeader('Content-Type')
        }));
        System.assertEquals(httpLifeCycle.Response_Body__c, response.getBody());
        System.assertEquals(httpLifeCycle.Response_Header__c, JSON.serialize(new Map<String, String>{
                'response' => response.getHeader('response')
        }));
        System.assertEquals(httpLifeCycle.Status_Code__c, 200);
        System.assertEquals(httpLifeCycle.Url__c, request.getEndpoint());
    }

    @IsTest
    static void testBehaviorWithHttpConstructor() {
        Test.setMock(HttpCalloutMock.class, new DropBoxConnectionTestMock());

        HttpRequest request = new HttpRequest();
        Http http = new Http();

        request.setEndpoint('callout:DropBoxGetFile/get_temporary_link');
        request.setMethod('POST');
        request.setHeader('Content-Type', 'application/json');
        request.setBody('{request body}');
        HttpResponse response = http.send(request);

        Test.startTest();
        new HttpLogger().logHttpUsingPlatformEvent(request, response);
        Test.stopTest();

        Http_Life_Cycle__c httpLifeCycle = [
                SELECT Request_Body__c, Request_Header__c,
                        Response_Body__c, Response_Header__c,
                        Status_Code__c, Url__c
                FROM Http_Life_Cycle__c
                LIMIT 1
        ];

        System.assertEquals(httpLifeCycle.Request_Body__c, request.getBody());
        System.assertEquals(httpLifeCycle.Request_Header__c, JSON.serialize(new Map<String, String>{
                'Content-Type' => request.getHeader('Content-Type')
        }));
        System.assertEquals(httpLifeCycle.Response_Body__c, response.getBody());
        System.assertEquals(httpLifeCycle.Response_Header__c, JSON.serialize(new Map<String, String>{
                'response' => response.getHeader('response')
        }));
        System.assertEquals(httpLifeCycle.Status_Code__c, 200);
        System.assertEquals(httpLifeCycle.Url__c, request.getEndpoint());
    }

    private class DropBoxConnectionTestMock implements HttpCalloutMock {

        public HttpResponse respond(HttpRequest request) {
            HttpResponse response = new HttpResponse();
            response.setStatusCode(200);
            response.setHeader('response', 'header');
            response.setBody('{response Body}');
            return response;
        }
    }
}