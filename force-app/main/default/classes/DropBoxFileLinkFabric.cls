/**
 * Created by AntonAntoniuk on 17.09.2019.
 */

public with sharing class DropBoxFileLinkFabric {

    @TestVisible
    private static DropBoxConnection dropBox = new DropBoxConnection();
    @TestVisible
    private static CacheController cacheController = new CacheController();

    public String getLinkForRecord(String fileId) {
        Product2Cache__c product2CacheSettings = Product2Cache__c.getAll().get('Product2FileUrl');
        String link;
        if (product2CacheSettings.isCacheTemporraryLink__c) {
            link = new DropBoxConnectionCachedProxy(dropBox, cacheController).getDownloadLink(fileId);
        } else {
            link = dropBox.getDownloadLink(fileId);
        }
        return link;
    }
}