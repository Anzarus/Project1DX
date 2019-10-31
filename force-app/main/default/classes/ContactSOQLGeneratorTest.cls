/**
 * Created by AntonAntoniuk on 04.09.2019.
 */

@IsTest
private class ContactSOQLGeneratorTest {
    @IsTest
    static void testGettingContactSOQL() {
        String resultSOQL;
        User user = getTestUser(true);
        System.runAs(user){
            resultSOQL = new ContactSOQLGenerator().generateContactSOQLWithoutWhere();
        }

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
                ' CleanStatus, IndividualId FROM Contact', resultSOQL);
    }

    @IsTest
    static void testExceptionSettingStrictRulesViaConstructor() {
        User user = getTestUser(false);
        System.runAs(user) {
            try {
                ContactSOQLGenerator contactSOQLGenerator = new ContactSOQLGenerator(true);

                contactSOQLGenerator.generateContactSOQLWithoutWhere();
            } catch (NoAccessException e) {
                System.assertEquals(e.getMessage(), e.getMessage());
            }
        }
    }

    @IsTest
    static void testExceptionSettingStrictRulesViaMethod() {
        User user = getTestUser(false);
        System.runAs(user) {
            try {
                ContactSOQLGenerator contactSOQLGenerator = new ContactSOQLGenerator();

                contactSOQLGenerator.setIsStrict(true);

                contactSOQLGenerator.generateContactSOQLWithoutWhere();
            } catch (NoAccessException e) {
                System.assertEquals(e.getMessage(), e.getMessage());
            }
        }
    }

    private static User getTestUser(Boolean isUserHaveAccess) {
        Profile profile = isUserHaveAccess ? [SELECT Id FROM Profile WHERE Name = 'System Administrator' LIMIT 1]
                : [SELECT Id FROM Profile WHERE Name = 'Chatter Free User' LIMIT 1];
        Profile profile = [SELECT Id FROM Profile WHERE Name = 'Chatter Free User' LIMIT 1];
        User testUser = new User(LastName = 'Robinson', Alias = 'Robi', Email = 'antonantonuk1999@gmail.com',
                Username = 'testUserProject1@gmail.com' + Datetime.now().getTime(), CommunityNickname = 'testUser',
                EmailEncodingKey = 'UTF-8', LanguageLocaleKey = 'en_US', LocaleSidKey = 'en_US', ProfileId = profile.Id,
                TimeZoneSidKey = 'America/Los_Angeles');

        return testUser;
    }
}