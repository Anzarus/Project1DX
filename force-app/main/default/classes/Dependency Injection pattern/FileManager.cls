/**
 * Created by AntonAntoniuk on 01.10.2019.
 */

public with sharing class FileManager {

    private ServiceConnection service;

    public FileManager(ServiceConnection service) {
        this.service = service;
    }

    public String getFileLink() {
        //get fileId from somewhere
        return service.getFileDownloadLink('fileId');
    }

    public String putFile() {
        //get fileId from somewhere
        return service.sendFile('fileId');
    }

    public String deleteFile() {
        //get fileId from somewhere
        return service.deleteFile('fileId');
    }
}