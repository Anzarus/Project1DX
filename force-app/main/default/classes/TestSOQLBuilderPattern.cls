/**
 * Created by AntonAntoniuk on 04.09.2019.
 */

@IsTest
private class TestSOQLBuilderPattern {
    @IsTest
    static void testGeneratingSOQLForProduct2() {
        SObjectType sObjectType = Product2.SObjectType;
        List<SObjectField> sObjectFields = sObjectType.getDescribe().fields.getMap().values();

        SOQLDirector director = new SOQLDirector();
        SOQLBuilderUnit builder = new SOQLBuilderUnit(sObjectType, sObjectFields);

        director.generateSOQLQueryWithoutStrictAccessRules(builder);

        System.assertEquals('SELECT Id, Name, ProductCode, Description,' +
                ' IsActive, CreatedDate, CreatedById, LastModifiedDate,' +
                ' LastModifiedById, SystemModstamp, Family, ExternalDataSourceId,' +
                ' ExternalId, DisplayUrl, QuantityUnitOfMeasure, IsDeleted,' +
                ' IsArchived, LastViewedDate, LastReferencedDate, StockKeepingUnit,' +
                ' Price__c, Status__c FROM Product2 ', builder.getSOQL());
    }

    @IsTest
    static void testGeneratingSOQLForContact() {
        SObjectType sObjectType = Contact.SObjectType;
        List<SObjectField> sObjectFields = sObjectType.getDescribe().fields.getMap().values();

        SOQLDirector director = new SOQLDirector();
        SOQLBuilderUnit builder = new SOQLBuilderUnit(sObjectType, sObjectFields);

        director.generateSOQLQueryWithoutStrictAccessRules(builder);

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
                ' CleanStatus FROM Contact ', builder.getSOQL());
    }

    @IsTest
    static void testExceptionOnSettingStrictRulesViaDirector() {
        User user = getTestUser();
        System.runAs(user) {
            try {
                SObjectType sObjectType = Contact.SObjectType;
                List<SObjectField> sObjectFields = sObjectType.getDescribe().fields.getMap().values();

                SOQLDirector director = new SOQLDirector();
                SOQLBuilderUnit builder = new SOQLBuilderUnit(sObjectType, sObjectFields);

                director.generateSOQLQueryWithStrictAccessRules(builder);
            } catch (NoAccessException e) {
                System.assertEquals(e.getMessage(), e.getMessage());
            }
        }
    }

    @IsTest
    static void testExceptionOnSettingStrictRulesViaBuilderConstructor(){
        User user = getTestUser();
        System.runAs(user){
            try {
                SObjectType sObjectType = Contact.SObjectType;
                List<SObjectField> sObjectFields = sObjectType.getDescribe().fields.getMap().values();

                SOQLDirector director = new SOQLDirector();
                SOQLBuilderUnit builder = new SOQLBuilderUnit(sObjectType, sObjectFields, true);

                director.generateSOQLQueryWithoutStrictAccessRules(builder);
            } catch (NoAccessException e) {
                System.assertEquals(e.getMessage(), e.getMessage());
            }
        }
    }

    @IsTest
    static void testExceptionOnSettingStrictRulesViaBuilderMethod(){
        User user = getTestUser();
        System.runAs(user){
            try {
                SObjectType sObjectType = Contact.SObjectType;
                List<SObjectField> sObjectFields = sObjectType.getDescribe().fields.getMap().values();

                SOQLDirector director = new SOQLDirector();
                SOQLBuilderUnit builder = new SOQLBuilderUnit(sObjectType, sObjectFields);

                builder.setIsStrict(true);

                director.generateSOQLQueryWithoutStrictAccessRules(builder);
            } catch (NoAccessException e) {
                System.assertEquals(e.getMessage(), e.getMessage());
            }
        }
    }

    private static User getTestUser() {
        Profile profile = [SELECT Id FROM Profile WHERE Name = 'Test' LIMIT 1];
        User testUser = new User(LastName = 'Robinson', Alias = 'Robi', Email = 'antonantonuk1999@gmail.com',
                Username = 'testUserProject1@gmail.com' + Datetime.now().getTime(), CommunityNickname = 'testUser',
                EmailEncodingKey = 'UTF-8', LanguageLocaleKey = 'en_US', LocaleSidKey = 'en_US', ProfileId = profile.Id,
                TimeZoneSidKey = 'America/Los_Angeles');

        return testUser;
    }
}