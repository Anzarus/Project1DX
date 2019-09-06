/**
 * Created by AntonAntoniuk on 04.09.2019.
 */

@IsTest
private class TestSOQLBuilderPattern {
    @IsTest
    static void testGeneratingSOQLForDifferentSObjects() {
        SObjectType sObjectType = Product2.SObjectType;
        List<SObjectField> sObjectFields = sObjectType.getDescribe().fields.getMap().values();

        SOQLBuilder builder = new SOQLBuilder();

        String productQuery = builder
                .setFields(sObjectFields)
                .setFrom(sObjectType)
                .setFrom('Product2')
                .build();

        String contactQuery = builder
                .reset()
                .setFrom('Contact')
                .setField(Contact.Id)
                .setField('Contact.LastName')
                .build();

        System.assertEquals('SELECT Id, Name, ProductCode, Description,' +
                ' IsActive, CreatedDate, CreatedById, LastModifiedDate,' +
                ' LastModifiedById, SystemModstamp, Family, ExternalDataSourceId,' +
                ' ExternalId, DisplayUrl, QuantityUnitOfMeasure, IsDeleted,' +
                ' IsArchived, LastViewedDate, LastReferencedDate, StockKeepingUnit,' +
                ' Price__c, Status__c FROM Product2', productQuery);

        System.assertEquals('SELECT Id, LastName FROM Contact', contactQuery);
    }

    @IsTest
    static void testExceptionOnAccessToObject() {
        User user = getTestUser();
        System.runAs(user) {
            try {
                SObjectType sObjectType = Product2.SObjectType;
                new SOQLBuilder()
                        .setField(Product2.Price__c)
                        .setFrom(sObjectType)
                        .build();
            } catch (NoAccessException e) {
                System.assertEquals(e.getMessage(), e.getMessage());
            }
        }
    }

    @IsTest
    static void testExceptionOnAccessToFieldIfRulesStrict() {
        User user = getTestUser();
        System.runAs(user) {
            try {
                new SOQLBuilder(true)
                        .setField(Contact.Name)
                        .setFrom(Contact.SObjectType)
                        .build();
            } catch (NoAccessException e) {
                System.assertEquals(e.getMessage(), e.getMessage());
            }
        }
    }

    @IsTest
    private static void testExceptionOnSettingDifferentObjectsWithoutReset() {
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
    private static void testExceptionOnSettingDifferentObjectsWithout() {
        SObjectType sObjectType = Contact.SObjectType;
        String query = new SOQLBuilder()
                .setFrom(sObjectType)
                .setField('Contact.FirstName')
                .setField('Contact.Account.Name')
                .build();


        System.assertEquals('SELECT Contact.FirstName, Contact.Account.Name from Contact', query);
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