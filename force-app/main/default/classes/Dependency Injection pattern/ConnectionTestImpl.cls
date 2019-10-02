/**
 * Created by AntonAntoniuk on 02.10.2019.
 */

public with sharing class ConnectionTestImpl implements ServiceConnection {

    public String getFileDownloadLink(String fileId) {
        return '1';
    }

    public String sendFile(String fileId) {
        return '2';
    }

    public String deleteFile(String fileId) {
        return '3';
    }
}
