/**
 * Created by AntonAntoniuk on 11.09.2019.
 */

public with sharing class DropBoxConnectionImpl implements DropBoxConnection {//todo

    public String getDownloadLink(String pathToFile) {
        HttpRequest request = new HttpRequest();
        Http http = new Http();
        String result;

        request.setEndpoint('callout:DropBoxGetFile/get_temporary_link');
        request.setMethod('POST');
        request.setHeader('Content-Type', 'application/json');
        request.setBody('{\"path\": \"' + pathToFile + '\"}');
        HttpResponse response = http.send(request);

        new HttpLogger().logHttpUsingPlatformEvent(request, response);

        if (response.getStatusCode() == 200) {
            Map<String, Object> resultMap = (Map<String, Object>) JSON.deserializeUntyped(response.getBody());
            result = String.valueOf(resultMap.get('link'));
        } else if (response.getStatusCode() == 404) {
            throw new DropBoxConnectionException('File not found!');
        } else {
            throw new DropBoxConnectionException(response.getBody());
        }
        return result;
    }

    public String deleteFiles(List<String> pathToFiles) {
        HttpRequest request = new HttpRequest();
        Http http = new Http();

        request.setEndpoint('callout:DropBoxGetFile/delete_batch');
        request.setMethod('POST');
        request.setHeader('Content-Type', 'application/json');
        request.setBody('{\"entries\": [' + createDelRequestBodyData(pathToFiles) + ']}');
        HttpResponse response = http.send(request);

        new HttpLogger().logHttpUsingPlatformEvent(request, response);

        if (response.getStatusCode() == 200) {
            Map<String, Object> resultMap = (Map<String, Object>) JSON.deserializeUntyped(response.getBody());
            return String.valueOf(resultMap.get('async_job_id'));
        } else {
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

    public Map<String, String> checkDeletedStatus(String jobId) {
        HttpRequest request = new HttpRequest();
        Http http = new Http();

        request.setEndpoint('callout:DropBoxGetFile/delete_batch/check');
        request.setMethod('POST');
        request.setHeader('Content-Type', 'application/json');
        request.setBody('{\"async_job_id\": \"' + jobId + '\"}');
        HttpResponse response = http.send(request);

        new HttpLogger().logHttpUsingPlatformEvent(request, response);

        if (response.getStatusCode() == 200) {
            return formResultMap(response, request);
        } else {
            throw new DropBoxConnectionException(response.getBody());
        }//todo redo to return all required values for log and body result
    }

    private Map<String, String> formResultMap(HttpResponse response, HttpRequest request) {
        List<String> responseHeader = new List<String>();
        for (String str : response.getHeaderKeys()) {
            responseHeader.add(str);
        }

        Map<String, String> resultMap = new Map<String, String>();
        resultMap.put('RequestBody', request.getBody());
        resultMap.put('RequestHeader', request.getHeader('Content-Type'));
        resultMap.put('ResponseBody', response.getBody());
        resultMap.put('ResponseHeader', String.valueOf(responseHeader));
        resultMap.put('StatusCode', String.valueOf(response.getStatusCode()));
        resultMap.put('Url', request.getEndpoint());
        return resultMap;
    }

    @TestVisible
    private class DropBoxConnectionException extends Exception {
    }
}