/**
 * Created by AntonAntoniuk on 11.09.2019.
 */

public with sharing class Product2FileFromDropBoxController {
    @AuraEnabled
    public static String getFileForThisRecord(String recordId) {
        Product2 product2 = [
                SELECT File_Id__c
                FROM Product2
                WHERE Id = :Id.valueOf(recordId)
        ];

        String link = LinkToFileInDropBoxGetter.getLink(product2.File_Id__c);
        if (link.contains('Error')) {
            String errorMessage = link.substringAfter(' ');
            switch on errorMessage {
                when '400' {
                    throw new LinkException('The server did not understand the request.');
                } when '401' {
                    throw new LinkException('The requested page needs a username and a password.');
                } when '404' {
                    throw new LinkException('The server can not find the requested page.');
                } when '500' {
                    throw new LinkException('The server met an unexpected condition.');
                }
            }
        }
        return link;
    }

    private class LinkException extends Exception {
    }
}