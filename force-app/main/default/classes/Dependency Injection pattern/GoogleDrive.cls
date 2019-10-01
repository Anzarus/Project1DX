/**
 * Created by AntonAntoniuk on 01.10.2019.
 */

public with sharing class GoogleDrive implements ServiceConnection {

    public String getFileDownloadLink(String fileId) {
        return 'Get GoogleDrive File Link';
    }

    public String sendFile(String fileId) {
        return 'Send File To GoogleDrive';
    }

    public String deleteFile(String fileId) {
        return 'Delete File From GoogleDrive';
    }
}