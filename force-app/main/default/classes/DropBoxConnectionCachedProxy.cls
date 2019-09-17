/**
 * Created by AntonAntoniuk on 16.09.2019.
 */

public with sharing class DropBoxConnectionCachedProxy implements DropBoxConnectionInterface {

    @TestVisible
    private CacheController cache = new CacheController();
    private DropBoxConnectionInterface dropBoxConnector;

    public DropBoxConnectionCachedProxy(DropBoxConnectionInterface dropBoxConnector) {
        this.dropBoxConnector = dropBoxConnector;
    }

    public String getDownloadLink(String fileId) {

        if (!cache.hasCache(fileId)) {
            cache.putCache(fileId, dropBoxConnector.getDownloadLink(fileId));
        }
        return cache.getCache(fileId);
    }
}