/**
 * Created by AntonAntoniuk on 05.11.2019.
 */

public with sharing class DropBoxConnectionUploadableImpl implements DropBoxConnectionUploadable {

    private String uploadFileEndpoint = 'callout:DropBoxUploadFile{0}';
    private String uploadParams =
            '\"path\": \"{0}\",' +
                    '\"mode\": \"{1}\",' +
                    '\"autorename\": {2},' +
                    '\"mute\": {3},' +
                    '\"strict_conflict\": {4}';
    private DropBoxConnection dropBoxConnection;

    public DropBoxConnectionUploadableImpl(DropBoxConnection dropBoxConnection){
        this.dropBoxConnection = dropBoxConnection;
    }

    public String getDownloadLink(String fileId) {
        return dropBoxConnection.getDownloadLink(fileId);
    }

    public String uploadFile(String filePath, Blob fileContent) {
        HttpRequest request = new HttpRequest();
        Http http = new Http();

        request.setEndpoint(String.format(uploadFileEndpoint, new List<Object>{
                '/upload'
        }));
        request.setMethod('POST');
        request.setHeader('Dropbox-API-Arg',
                '{' +
                        String.format(uploadParams, new List<Object>{
                                filePath, 'add', true, false, false
                        })
                        + '}');
        request.setHeader('Content-Type', 'application/octet-stream');
        request.setBodyAsBlob(fileContent);

        HttpResponse response = http.send(request);

        if (response.getStatusCode() == 200) {
            Map<String, Object> result = (Map<String, Object>) JSON.deserializeUntyped(response.getBody());
            return String.valueOf(result.get('path_display'));
        }
        throw new DropBoxConnectionException(response.getBody());
    }

    @TestVisible
    private class DropBoxConnectionException extends Exception {
    }
}