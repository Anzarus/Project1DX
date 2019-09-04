/**
 * Created by AntonAntoniuk on 04.09.2019.
 */

@IsTest
private class TestSOQLGenerator {
    @IsTest
    static void testGeneratingSOQLForProduct2 () {
        SOQLGenerator soqlGenerator = new SOQLGenerator(Product2.SObjectType);

        String resultProduct2SOQL = soqlGenerator.generateSOQL();

        System.assertEquals('SELECT Id, Name, ProductCode, Description,' +
                ' IsActive, CreatedDate, CreatedById, LastModifiedDate,' +
                ' LastModifiedById, SystemModstamp, Family, ExternalDataSourceId,' +
                ' ExternalId, DisplayUrl, QuantityUnitOfMeasure, IsDeleted,' +
                ' IsArchived, LastViewedDate, LastReferencedDate, StockKeepingUnit,' +
                ' Price__c, Status__c FROM Product2 ', resultProduct2SOQL);
    }

    @IsTest
    static void testGeneratingSOQLForContact(){
        SOQLGenerator soqlGenerator = new SOQLGenerator(Contact.SObjectType);

        String resultContactSOQL = soqlGenerator.generateSOQL();

        System.assertEquals('SELECT Id, IsDeleted, MasterRecordId, AccountId,' +
                ' LastName, FirstName, Salutation, Name, OtherStreet, OtherCity,' +
                ' OtherState, OtherPostalCode, OtherCountry, OtherLatitude,' +
                ' OtherLongitude, OtherGeocodeAccuracy, OtherAddress, MailingStreet,' +
                ' MailingCity, MailingState, MailingPostalCode, MailingCountry,' +
                ' MailingLatitude, MailingLongitude, MailingGeocodeAccuracy,' +
                ' MailingAddress, Phone, Fax, MobilePhone, HomePhone, OtherPhone,' +
                ' AssistantPhone, ReportsToId, Email, Title, Department, AssistantName,' +
                ' LeadSource, Birthdate, Description, OwnerId, HasOptedOutOfEmail,' +
                ' HasOptedOutOfFax, DoNotCall, CreatedDate, CreatedById, LastModifiedDate,' +
                ' LastModifiedById, SystemModstamp, LastActivityDate, LastCURequestDate,' +
                ' LastCUUpdateDate, LastViewedDate, LastReferencedDate, EmailBouncedReason,' +
                ' EmailBouncedDate, IsEmailBounced, PhotoUrl, Jigsaw, JigsawContactId,' +
                ' CleanStatus FROM Contact ', resultContactSOQL);
    }
}