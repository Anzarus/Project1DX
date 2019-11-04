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

    public Map<String, String> checkDeletedStatus(String jobId) {
        HttpRequest request = new HttpRequest();
        Http http = new Http();

        request.setEndpoint('callout:DropBoxGetFile/delete_batch/check');
        request.setMethod('POST');
        request.setHeader('Content-Type', 'application/json');
        request.setBody('{\"async_job_id\": \"' + jobId + '\"}');
        HttpResponse response = http.send(request);

        if (response.getStatusCode() == 200) {
            return formResultMap(response, request);
        } else {
            throw new DropBoxConnectionException(response.getBody());
        }
    }

    private Map<String, String> formResultMap(HttpResponse response, HttpRequest request) {
        return new Map<String, String>{
                'RequestBody' => request.getBody(),
                'RequestHeader' => JSON.serialize(getHeader(null, request)),
                'ResponseBody' => response.getBody(),
                'ResponseHeader' => JSON.serialize(getHeader(response, null)),
                'StatusCode' => String.valueOf(response.getStatusCode()),
                'Url' => request.getEndpoint()
        };
      }

    private Map<String, String> getHeader(HttpResponse response, HttpRequest request) {
        Map<String, String> header = new Map<String, String>();
        if (response != null) {
            for (String key : response.getHeaderKeys()) {
                header.put(key, response.getHeader(key));
            }
        } else if (request != null) {
            header.put('Content-Type', request.getHeader('Content-Type'));
        }
        return header;
    }

    @TestVisible
    private class DropBoxConnectionException extends Exception {
    }
}