/**
 * Created by AntonAntoniuk on 11.09.2019.
 */

public with sharing class DropBoxConnection implements DropBoxConnectionInterface {

    public String getDownloadLink(String pathToFile) {
        HttpRequest request = new HttpRequest();
        Http http = new Http();
        String result;

        request.setEndpoint('callout:DropBoxGetFile/get_temporary_link');
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

    public void deleteFiles(List<String> pathToFiles) {
        HttpRequest request = new HttpRequest();
        Http http = new Http();

        request.setEndpoint('callout:DropBoxGetFile/delete_batch');
        request.setMethod('POST');
        request.setHeader('Content-Type', 'application/json');
        request.setBody('{\"entries\": [' + createDelRequestBodyData(pathToFiles) + ']}');
        HttpResponse response = http.send(request);

        if (response.getStatusCode() != 200) {
            throw new DropBoxConnectionException(response.getBody());
        }
    }

    private String createDelRequestBodyData(List<String> pathToFiles) {
        String bodyData = '';
        for (Integer i = 0; i < pathToFiles.size(); i++) {
            bodyData += '{\"path\": \"' + pathToFiles[i] + '\"}';
            if (i + 1 == pathToFiles.size()) continue;
            bodyData += ', ';
        }
        return bodyData;
    }

    @TestVisible
    private class DropBoxConnectionException extends Exception {
    }
}