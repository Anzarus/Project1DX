/**
 * Created by AntonAntoniuk on 11.09.2019.
 */

public with sharing class DropBoxConnectionImpl implements DropBoxConnection {

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

    public Map<String, List<String>> checkDeletedStatus(String jobId) {
        HttpRequest request = new HttpRequest();
        Http http = new Http();

        request.setEndpoint('callout:DropBoxGetFile/delete_batch/check');
        request.setMethod('POST');
        request.setHeader('Content-Type', 'application/json');
        request.setBody('{\"async_job_id\": \"' + jobId + '\"}');
        HttpResponse response = http.send(request);

//        new HttpLogger().logHttpUsingPlatformEvent(request, response);

        if (response.getStatusCode() == 200) {
            Map<String, Object> resultMap = (Map<String, Object>) JSON.deserializeUntyped(response.getBody());
            String resultMessage = String.valueOf(resultMap.get('.tag'));
            if (resultMessage == 'complete') {
                List<Object> entries = (List<Object>) resultMap.get('entries');
                return analyzeMessage(entries);
            }
            return null;
        } else {
            throw new DropBoxConnectionException(response.getBody());
        }
    }

    private Map<String, List<String>> analyzeMessage(List<Object> entries) {
        Map<String, Object> fileStatus;
        List<String> successDeletedFiles = new List<String>();
        for (Object obj : entries) {
            fileStatus = (Map<String, Object>) obj;
            if (fileStatus.get('.tag') == 'success') {
                Map<String, Object> metadata = (Map<String, Object>) fileStatus.get('metadata');
                successDeletedFiles.add(String.valueOf(metadata.get('path_display')));
            }
        }
        System.debug(successDeletedFiles);
        if (successDeletedFiles.size() == entries.size()) {
            return new Map<String, List<String>>{
                    'result' => new List<String>{
                            'Success'
                    },
                    'successFiles' => successDeletedFiles
            };
        } else {
            return new Map<String, List<String>>{
                    'result' => new List<String>{
                            'Failed'
                    },
                    'successFiles' => successDeletedFiles
            };
        }
    }

    @TestVisible
    private class DropBoxConnectionException extends Exception {
    }
}