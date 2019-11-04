/**
 * Created by AntonAntoniuk on 17.09.2019.
 */

public with sharing class CacheController {

    private Cache.OrgPartition productPartition = Cache.Org.getPartition('local.Product2LinkCache');

    public Boolean hasCache(String prodId) {
        return productPartition.contains(prodId);
    }

    public String getCache(String prodId) {
        return (String) productPartition.get(prodId);
    }

    public void putCache(String key, String value) {
        productPartition.put(key, value);
    }
}
