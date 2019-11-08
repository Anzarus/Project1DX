/**
 * Created by AntonAntoniuk on 16.09.2019.
 */

public with sharing class DropBoxConnectionCachedProxy implements DropBoxConnection {

    @TestVisible
    private CacheController cache = new CacheController();
    private DropBoxConnection dropBoxConnector;

    public DropBoxConnectionCachedProxy(DropBoxConnection dropBoxConnector) {
        this.dropBoxConnector = dropBoxConnector;
    }

    public String getDownloadLink(String fileId) {
        String key = String.valueOf(fileId.hashCode());
        if(!cache.hasCache(key)) {
            cache.putCache(key, dropBoxConnector.getDownloadLink(fileId));
        }
        return cache.getCache(key);
    }
}