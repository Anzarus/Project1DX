/**
 * Created by AntonAntoniuk on 24.09.2019.
 */

@IsTest
private class DropBoxFileLinkFabricTest {
    @IsTest
    static void defaultConnectionTest() {
        Product2Cache__c testCacheSettings = new Product2Cache__c(
                Name = 'Product2FileUrl',
                isCacheTemporraryLink__c = false);
        insert testCacheSettings;

        Test.startTest();
        DropBoxFileLinkFabric fabric = new DropBoxFileLinkFabric();
        DropBoxConnection connection = fabric.getDropBoxConnector();
        Test.stopTest();

        System.assert(connection instanceof DropBoxConnectionImpl);
    }

    @IsTest
    static void proxyConnectionTest() {
        Product2Cache__c testCacheSettings = new Product2Cache__c(
                Name = 'Product2FileUrl',
                isCacheTemporraryLink__c = true
        );
        insert testCacheSettings;

        Test.startTest();
        DropBoxFileLinkFabric fabric = new DropBoxFileLinkFabric();
        DropBoxConnection connectionProxy = fabric.getDropBoxConnector();
        Test.stopTest();

        System.assert(connectionProxy instanceof DropBoxConnectionCachedProxy);
    }
}