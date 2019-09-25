/**
 * Created by AntonAntoniuk on 17.09.2019.
 */

public with sharing class DropBoxFileLinkFabric {

    public DropBoxConnection getDropBoxConnector() {
        Product2Cache__c product2CacheSettings = Product2Cache__c.getAll().get('Product2FileUrl');
        DropBoxConnection connection = new DropBoxConnectionImpl();
        if (product2CacheSettings.isCacheTemporraryLink__c) {
            return new DropBoxConnectionCachedProxy(connection);
        } else {
            return connection;
        }
    }
}