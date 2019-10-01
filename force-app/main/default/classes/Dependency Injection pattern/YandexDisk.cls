/**
 * Created by AntonAntoniuk on 01.10.2019.
 */

public with sharing class YandexDisk implements ServiceConnection{

    public String getFileDownloadLink(String fileId) {
        return 'Get YandexDisk File Link';
    }

    public String sendFile(String fileId) {
        return 'Send File To YandexDisk';
    }

    public String deleteFile(String fileId) {
        return 'Delete File From YandexDisk';
    }
}