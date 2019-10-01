/**
 * Created by AntonAntoniuk on 01.10.2019.
 */

public with sharing class OneDrive implements ServiceConnection{

    public String getFileDownloadLink(String fileId) {
        return 'Get OneDrive File Link';
    }

    public String sendFile(String fileId) {
        return 'Send File To OneDrive';
    }

    public String deleteFile(String fileId) {
        return 'Delete File From OneDrive';
    }
}