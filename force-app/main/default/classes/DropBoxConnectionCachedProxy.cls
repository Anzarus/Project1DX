/**
 * Created by AntonAntoniuk on 16.09.2019.
 */

public with sharing class DropBoxConnectionCachedProxy implements DropBoxConnectionInterface {

    private CacheController cacheController;
    private DropBoxConnectionInterface dropBoxConnector;

    public DropBoxConnectionCachedProxy(DropBoxConnectionInterface dropBoxConnector,
            CacheController cache) {
        this.dropBoxConnector = dropBoxConnector;
        this.cacheController = cache;
    }

    public String getDownloadLink(String fileId) {
        String key = String.valueOf(fileId.hashCode());
        if (!cacheController.hasCache(key)) {
            cacheController.putCache(key, dropBoxConnector.getDownloadLink(fileId));
        }
        return cacheController.getCache(key);
    }
}