/**
 * Created by AntonAntoniuk on 24.10.2019.
 */

@IsTest
private class RegistrationHandlerAuthTest {
    @TestSetup
    static void createUser() {
        Profile profile = [SELECT Id FROM Profile WHERE Name = 'Standard User' LIMIT 1];

        User testUser = new User(LastName = 'Robinson', Alias = 'Robi', Email = 'antonantonuk1999@gmail.com',
                Username = 'testUserProject1@gmail.com' + Datetime.now().getTime(), CommunityNickname = 'testUser',
                EmailEncodingKey = 'UTF-8', LanguageLocaleKey = 'en_US', LocaleSidKey = 'en_US', ProfileId = profile.Id,
                TimeZoneSidKey = 'America/Los_Angeles', FederationIdentifier = 'google-oauth2|' + 'testIdentifier');

        insert testUser;
    }

    @IsTest
    static void testOnCreate() {
        Auth.UserData data = new Auth.UserData(
                'testIdentifier', null, null,
                null, null, null, null,
                null, 'Google', null, null
        );

        RegistrationHandlerAuth registrationHandlerAuth = new RegistrationHandlerAuth();

        User resultUser = registrationHandlerAuth.createUser(null, data);
        System.assertEquals([
                SELECT Id
                FROM User
                WHERE Email = 'antonantonuk1999@gmail.com'
        ].get(0).Id, resultUser.Id);
    }

    @IsTest
    static void testExceptionOnCreate() {
        Auth.UserData data = new Auth.UserData(
                'Identifier', null, null,
                null, null, null, null,
                null, null, null, null
        );

        RegistrationHandlerAuth registrationHandlerAuth = new RegistrationHandlerAuth();

        try {
            registrationHandlerAuth.createUser(null, data);
        } catch (RegistrationHandlerAuth.RegistrationHandlerAuthException e) {
            System.assertEquals('This User can not be found!', e.getMessage());
        }
    }

    @IsTest
    static void testOnUpdate() {
        Auth.UserData data = new Auth.UserData(
                'testIdentifier', null, null,
                null, null, null, null,
                null, 'Google', null, null
        );

        User user = [SELECT Id FROM User WHERE Email = 'antonantonuk1999@gmail.com'].get(0);

        RegistrationHandlerAuth registrationHandlerAuth = new RegistrationHandlerAuth();

        User resultUser = registrationHandlerAuth.checkUser(user.Id, data);
        System.assertEquals(user.Id, resultUser.Id);
    }

    @IsTest
    static void testExceptionOnUpdate() {
        Auth.UserData data = new Auth.UserData(
                'Identifier', null, null,
                null, null, null, null,
                null, null, null, null
        );

        User user = [SELECT Id FROM User WHERE Email = 'antonantonuk1999@gmail.com'].get(0);

        RegistrationHandlerAuth registrationHandlerAuth = new RegistrationHandlerAuth();

        try {
            registrationHandlerAuth.updateUser(user.Id, null, data);
        } catch (RegistrationHandlerAuth.RegistrationHandlerAuthException e) {
            System.assertEquals('This User can not be found!', e.getMessage());
        }
    }
}