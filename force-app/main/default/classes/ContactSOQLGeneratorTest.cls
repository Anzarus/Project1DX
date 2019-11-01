/**
 * Created by AntonAntoniuk on 04.09.2019.
 */

@IsTest
private class ContactSOQLGeneratorTest {
    @IsTest
    static void testGettingContactSOQL() {

        ContactSOQLGenerator contactSOQLGenerator = new ContactSOQLGenerator();

        String expectedResult = '';

        for (SObjectField field : Schema.SObjectType.Contact.fields.getMap().values()) {
            if (field.getDescribe().isAccessible()) {
                expectedResult += field + ', ';
            }
        }

        String resultSOQL = contactSOQLGenerator.generateContactSOQLWithoutWhere();

        System.assertEquals('SELECT ' + expectedResult.substring(0, expectedResult.length() - 2)
                + ' FROM Contact', resultSOQL);
    }

    @IsTest
    static void testExceptionSettingStrictRulesViaConstructor() {
        User user = getTestUser();
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
        User user = getTestUser();
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

    private static User getTestUser() {
        Profile profile = [SELECT Id FROM Profile WHERE Name = 'Chatter Free User' LIMIT 1];
        User testUser = new User(LastName = 'Robinson', Alias = 'Robi', Email = 'antonantonuk1999@gmail.com',
                Username = 'testUserProject1@gmail.com' + Datetime.now().getTime(), CommunityNickname = 'testUser',
                EmailEncodingKey = 'UTF-8', LanguageLocaleKey = 'en_US', LocaleSidKey = 'en_US', ProfileId = profile.Id,
                TimeZoneSidKey = 'America/Los_Angeles');

        return testUser;
    }
}