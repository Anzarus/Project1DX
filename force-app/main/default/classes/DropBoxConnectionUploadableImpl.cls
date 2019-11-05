/**
 * Created by AntonAntoniuk on 05.11.2019.
 */

public with sharing class DropBoxConnectionUploadableImpl implements DropBoxConnectionUploadable {

    private DropBoxConnection dropBoxConnection;

    public DropBoxConnectionUploadableImpl(DropBoxConnection dropBoxConnection){
        this.dropBoxConnection = dropBoxConnection;
    }

    public String getDownloadLink(String fileId) {
        return dropBoxConnection.getDownloadLink(fileId);
    }

    public String uploadFile(String fileId, String fileContent) {
        String responseBody =  dropBoxConnection.uploadFile(fileId, fileContent);
        return getFileId(responseBody);
    }

    public String getFileId(String responseBody){
        Map<String, Object> result = (Map<String, Object>) JSON.deserializeUntyped(responseBody);
        String resultPath = String.valueOf(result.get('path_display'));
        return resultPath;
    }
}