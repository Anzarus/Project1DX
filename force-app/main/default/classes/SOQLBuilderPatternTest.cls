/**
 * Created by AntonAntoniuk on 04.09.2019.
 */

@IsTest
private class SOQLBuilderPatternTest {

    @IsTest
    static void testGeneratingSOQLForDifferentSObjects() {
        SObjectType sObjectType = Task.SObjectType;
        List<SObjectField> sObjectFields = new List<SObjectField>{
                Task.AccountId, Task.Type, Task.CreatedById, Task.OwnerId
        };

        SOQLBuilder builder = new SOQLBuilder();

        String taskQuery = builder
                .setFields(sObjectFields)
                .setFrom(sObjectType)
                .setFrom('Task')
                .build();

        String contactQuery = builder
                .reset()
                .setFrom('Contact')
                .setField(Contact.Id)
                .setField('Contact.LastName')
                .setSecurityEnforced()
                .build();

        System.assertEquals('SELECT AccountId, Type, CreatedById, OwnerId FROM Task', taskQuery);

        System.assertEquals('SELECT Id, Contact.LastName FROM Contact WITH SECURITY_ENFORCED', contactQuery);
    }

    @IsTest
    static void testGeneratingWithStrict() {
        SObjectType sObjectType = Contact.SObjectType;
        String query = new SOQLBuilder(true, true)
                .setFrom(sObjectType)
                .setField('Contact.Account.Name')
                .build();

        System.assertEquals('SELECT Contact.Account.Name FROM Contact', query);
    }

    @IsTest
    static void testGeneratingWithStrictAndChildToParent() {
        SObjectType sObjectType = Contact.SObjectType;
        String query = new SOQLBuilder(true, true)
                .setFrom(sObjectType)
                .setFields(new SObjectField[]{
                        Contact.Name, Account.Name
                })
                .build();

        System.assertEquals('SELECT Contact.Name, Account.Name FROM Contact', query);
    }

    @IsTest
    static void testExceptionOnTypingNonValidValue() {
        try {
            new SOQLBuilder(true)
                    .setField('566sccs')
                    .setFrom(Contact.SObjectType)
                    .build();
        } catch (SOQLBuilder.BuilderSOQLException e) {
            System.assertEquals(e.getMessage(), e.getMessage());
        }
    }

    @IsTest
    static void testExceptionOnMissedRequiredValues() {
        try {
            new SOQLBuilder().build();
        } catch (SOQLBuilder.BuilderSOQLException e) {
            System.assertEquals(e.getMessage(), e.getMessage());
        }
    }

    @IsTest
    static void testExceptionOnSettingDifferentObjectsWithoutResetUsingSObjectType() {
        SObjectType sObjectType = Contact.SObjectType;
        try {
            new SOQLBuilder()
                    .setFrom('Account')
                    .setFrom(sObjectType)
                    .setField('Account.Name')
                    .build();
        } catch (Exception e) {
            System.assertEquals(e.getMessage(), e.getMessage());
        }
    }

    @IsTest
    static void testExceptionOnSettingDifferentObjectsWithoutResetUsingString() {
        SObjectType sObjectType = Contact.SObjectType;
        try {
            new SOQLBuilder()
                    .setFrom(sObjectType)
                    .setFrom('Account')
                    .setField('Account.Name')
                    .build();
        } catch (Exception e) {
            System.assertEquals(e.getMessage(), e.getMessage());
        }
    }

    @IsTest
    static void testExceptionOnAccessToObjectUsingSObjectType() {
        User user = getTestUser();
        System.runAs(user) {
            try {
                SObjectType sObjectType = Product2.SObjectType;
                new SOQLBuilder()
                        .setField(Product2.IsActive)
                        .setFrom(sObjectType)
                        .build();
            } catch (NoAccessException e) {
                System.assertEquals(e.getMessage(), e.getMessage());
            }
        }
    }

    @IsTest
    static void testExceptionOnAccessToObjectUsingString() {
        User user = getTestUser();
        System.runAs(user) {
            try {
                new SOQLBuilder()
                        .setField(Product2.IsActive)
                        .setFrom('Product2')
                        .build();
            } catch (NoAccessException e) {
                System.assertEquals(e.getMessage(), e.getMessage());
            }
        }
    }

    @IsTest
    static void testExceptionOnAccessToObjectUsingStringInChildToParent() {
        User user = getTestUser();
        System.runAs(user) {
            try {
                new SOQLBuilder(true, true)
                        .setField('Product2.CreatedBy.Alias')
                        .setFrom('Product2')
                        .build();
            } catch (NoAccessException e) {
                System.assertEquals(e.getMessage(), e.getMessage());
            }
        }
    }

    @IsTest
    static void testExceptionOnAccessToFieldIfRulesStrictUsingArrayOfFieldTypes() {
        User user = getTestUser();
        System.runAs(user) {
            try {
                new SOQLBuilder(true)
                        .setFields(new SObjectField[]{
                        Contact.Name
                })
                        .setFrom(Contact.SObjectType)
                        .build();
            } catch (NoAccessException e) {
                System.assertEquals(e.getMessage(), e.getMessage());
            }
        }
    }

    @IsTest
    static void testExceptionOnAccessToFieldIfRulesStrictUsingFieldType() {
        User user = getTestUser();
        System.runAs(user) {
            try {
                new SOQLBuilder(true)
                        .setFrom(Contact.SObjectType)
                        .setField(Contact.Name)
                        .build();
            } catch (NoAccessException e) {
                System.assertEquals(e.getMessage(), e.getMessage());
            }
        }
    }

    @IsTest
    static void testExceptionOnAccessToFieldIfRulesStrictUsingString() {
        User user = getTestUser();
        System.runAs(user) {
            try {
                new SOQLBuilder(true)
                        .setField('Contact.LastName')
                        .setFrom(Account.SObjectType)
                        .build();
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