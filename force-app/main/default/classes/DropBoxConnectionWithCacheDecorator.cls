/**
 * Created by AntonAntoniuk on 16.09.2019.
 */

public with sharing class DropBoxConnectionWithCacheDecorator extends DropBoxConnectionBaseDecorator {

    private String prodId;

    public DropBoxConnectionWithCacheDecorator(DropBoxConnectionInterface wrappee, String prodId) {
        super(wrappee);
        this.prodId = prodId;
    }

    public override String getDownloadLink(String pathToFile) {
        Product2LinkCache cache = new Product2LinkCache();
        if (!cache.hasCache(prodId)) {
            cache.putCache(prodId, super.getDownloadLink(pathToFile));
        }
        return cache.getCache(prodId);
    }

    private class Product2LinkCache /*implements Cache.CacheBuilder*/ {

        /*private Object doLoad(String productId) {
            return ;
        }*/

        private Cache.OrgPartition productPartition = Cache.Org.getPartition('local.Product2LinkCache');

        Boolean hasCache(String prodId) {
            if (productPartition.contains(prodId)) {
                return true;
            }
            return false;
        }

        String getCache(String prodId) {
            return (String) productPartition.get(prodId);
        }

        void putCache(String key, String value) {
            productPartition.put(key, value, 60);
        }
    }
}