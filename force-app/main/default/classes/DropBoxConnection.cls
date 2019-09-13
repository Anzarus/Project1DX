/**
 * Created by AntonAntoniuk on 11.09.2019.
 */

public with sharing class DropBoxConnection {

    public String getDownloadLink(String pathToFile) {
        HttpRequest request = new HttpRequest();
        Http http = new Http();
        String result;

        request.setEndpoint('callout:DropBoxGetFile');
        request.setMethod('POST');
        request.setHeader('Content-Type', 'application/json');
        request.setBody('{\"path\": \"' + pathToFile + '\"}');
        HttpResponse response = http.send(request);

        if (response.getStatusCode() == 200) {
            Map<String, Object> resultMap = (Map<String, Object>) JSON.deserializeUntyped(response.getBody());
            result = String.valueOf(resultMap.get('link'));
        } else {
            throw new DropBoxConnectionException(response.getBody());
        }
        return result;
    }

    @TestVisible
    private class DropBoxConnectionException extends Exception{
    }
}