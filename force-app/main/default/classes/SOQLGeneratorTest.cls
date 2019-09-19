/**
 * Created by AntonAntoniuk on 04.09.2019.
 */

@IsTest
private class SOQLGeneratorTest {
    @IsTest
    static void testGeneratingSOQLForProduct2 () {
        SOQLGenerator soqlGenerator = new SOQLGenerator(Product2.SObjectType);

        String resultProduct2SOQL = soqlGenerator.generateSOQL();

        System.assertEquals('SELECT Id, Name, ProductCode, Description,' +
                ' IsActive, CreatedDate, CreatedById, LastModifiedDate,' +
                ' LastModifiedById, SystemModstamp, Family, ExternalDataSourceId,' +
                ' ExternalId, DisplayUrl, QuantityUnitOfMeasure, IsDeleted,' +
                ' IsArchived, LastViewedDate, LastReferencedDate, StockKeepingUnit,' +
                ' File_Id__c, Price__c, Status__c FROM Product2 ', resultProduct2SOQL);
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
                ' CleanStatus, IndividualId FROM Contact ', resultContactSOQL);
    }

    @IsTest
    static void testExceptionSettingStrictRulesViaConstructor(){
        User user = getTestUser();
        System.runAs(user){
            try {
                SOQLGenerator soqlGenerator = new SOQLGenerator(Contact.SObjectType, true);

                soqlGenerator.generateSOQL();
            } catch (NoAccessException e) {
                System.assertEquals(e.getMessage(), e.getMessage());
            }
        }
    }

    @IsTest
    static void testExceptionSettingStrictRulesViaMethod() {
        User user = getTestUser();
        System.runAs(user) {
            try {
                SOQLGenerator soqlGenerator = new SOQLGenerator(Product2.SObjectType);

                soqlGenerator.setIsStrict(true);

                soqlGenerator.generateSOQL();
            } catch (NoAccessException e) {
                System.assertEquals(e.getMessage(), e.getMessage());
            }
        }
    }

    private static User getTestUser() {
        Profile profile = [SELECT Id FROM Profile WHERE Name = 'Chatter Free User' LIMIT 1];
        User testUser = new User(LastName = 'Robinson', Alias = 'Robi', Email = 'antonantonuk1999@gmail.com',
                Username = 'testUserProject1@gmail.com' + Datetime.now().getTime(), CommunityNickname = 'testUser',
                EmailEncodingKey = 'UTF-8', LanguageLocaleKey = 'en_US', LocaleSidKey = 'en_US', ProfileId = profile.Id,
                TimeZoneSidKey = 'America/Los_Angeles');

        return testUser;
    }
}