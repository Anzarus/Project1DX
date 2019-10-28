/**
 * Created by AntonAntoniuk on 07.10.2019.
 */

@IsTest
private class UnitOfWorkTest {
    @IsTest
    static void testInsertByOne() {
        UnitOfWork unitOfWork = new UnitOfWork(
                new Set<SObjectType>{
                        Account.SObjectType, Contact.SObjectType
                }
        );

        Account acc;
        Contact cont;
        for (Integer i = 0; i < 5; i++) {
            acc = new Account(Name = 'Account' + i);
            unitOfWork.addToInsert(acc);
            for (Integer j = 0; j < 10; j++) {
                cont = new Contact(LastName = acc.Name + ':Contact' + j);
                unitOfWork.addToInsert(cont);
            }
        }
        unitOfWork.commitWork();

        System.assertEquals(5, [SELECT Id FROM Account].size());
        System.assertEquals(50, [SELECT Id FROM Contact].size());
    }

    @IsTest
    static void testInsertByList() {
        UnitOfWork unitOfWork = new UnitOfWork(
                new Set<SObjectType>{
                        Lead.SObjectType
                }
        );

        unitOfWork.addToInsert(new List<Lead>{
                new Lead(LastName = 'Lead 1', Company = 'Lead 1'),
                new Lead(LastName = 'Lead 2', Company = 'Lead 2')
        });

        unitOfWork.commitWork();

        System.assertEquals(2, [SELECT Id FROM Lead].size());
    }

    @IsTest
    static void testInsertByOneNullPointerException() {
        UnitOfWork unitOfWork = new UnitOfWork(
                new Set<SObjectType>{
                        Contact.SObjectType
                }
        );
        try {
            Contact cont;
            unitOfWork.addToInsert(cont);
        } catch (UnitOfWork.UnitOfWorkException e) {
            System.assertEquals('SObject could not be null!', e.getMessage());
        }
    }

    @IsTest
    static void testInsertByOneWithRelationsNullPointerException() {
        UnitOfWork unitOfWork = new UnitOfWork(
                new Set<SObjectType>{
                        Contact.SObjectType
                }
        );
        try {
            Contact cont;
            unitOfWork.addToInsert(cont, Contact.AccountId, new Account());
        } catch (UnitOfWork.UnitOfWorkException e) {
            System.assertEquals('Child could not be null!', e.getMessage());
        }
    }

    @IsTest
    static void testInsertByListNullPointerException() {
        UnitOfWork unitOfWork = new UnitOfWork(
                new Set<SObjectType>{
                        Contact.SObjectType
                }
        );
        try {
            List<Contact> cont;
            unitOfWork.addToInsert(cont);
        } catch (UnitOfWork.UnitOfWorkException e) {
            System.assertEquals('The list should be initialized and have at list one value!', e.getMessage());
        }
    }

    @IsTest
    static void testUpdateByOne() {
        testInsertByOne();

        UnitOfWork unitOfWork = new UnitOfWork(
                new Set<SObjectType>{
                        Account.SObjectType, Contact.SObjectType
                }
        );

        List<Account> accounts = [SELECT Name FROM Account];
        List<Contact> contacts = [SELECT LastName FROM Contact];

        for (Account acc : accounts) {
            acc.Name = 'new';
            unitOfWork.addToUpdate(acc);
        }
        for (Contact cont : contacts) {
            cont.LastName = 'new';
            unitOfWork.addToUpdate(cont);
        }
        unitOfWork.commitWork();

        System.assertEquals(5, [SELECT Id FROM Account WHERE Name = :'new'].size());
        System.assertEquals(50, [SELECT Id FROM Contact WHERE LastName = :'new'].size());
    }

    @IsTest
    static void testUpdateByOneWithRelations() {
        testInsertByOne();

        UnitOfWork unitOfWork = new UnitOfWork(
                new Set<SObjectType>{
                        Account.SObjectType, Contact.SObjectType
                }
        );

        List<Account> accounts = [SELECT Name FROM Account];
        List<Contact> contacts = [SELECT LastName FROM Contact];

        for (Contact cont : contacts) {
            cont.LastName = 'new';
            unitOfWork.addToUpdate(cont, Contact.AccountId, accounts[0]);
        }
        unitOfWork.commitWork();

        System.assertEquals(50,
                [SELECT Id FROM Contact WHERE LastName = :'new' AND AccountId = :accounts[0].Id].size());
    }

    @IsTest
    static void testUpdateByList() {
        testInsertByList();

        UnitOfWork unitOfWork = new UnitOfWork(
                new Set<SObjectType>{
                        Lead.SObjectType
                }
        );

        List<Lead> leads = [SELECT LastName, Company FROM Lead];
        for (Lead lead : leads) {
            lead.LastName = 'new';
        }
        unitOfWork.addToUpdate(leads);
        unitOfWork.commitWork();

        System.assertEquals(2, [SELECT Id FROM Lead WHERE LastName = :'new'].size());
    }

    @IsTest
    static void testUpdateByOneNullPointerException() {
        UnitOfWork unitOfWork = new UnitOfWork(
                new Set<SObjectType>{
                        Contact.SObjectType
                }
        );
        try {
            Contact cont;
            unitOfWork.addToUpdate(cont);
        } catch (UnitOfWork.UnitOfWorkException e) {
            System.assertEquals('SObject could not be null!', e.getMessage());
        }
    }

    @IsTest
    static void testUpdateByOneWithRelationsNullPointerException() {
        UnitOfWork unitOfWork = new UnitOfWork(
                new Set<SObjectType>{
                        Contact.SObjectType
                }
        );
        try {
            Contact cont;
            unitOfWork.addToUpdate(cont, Contact.AccountId, new Account());
        } catch (UnitOfWork.UnitOfWorkException e) {
            System.assertEquals('Child could not be null!', e.getMessage());
        }
    }

    @IsTest
    static void testUpdateByListNullPointerException() {
        UnitOfWork unitOfWork = new UnitOfWork(
                new Set<SObjectType>{
                        Contact.SObjectType
                }
        );
        try {
            List<Contact> cont;
            unitOfWork.addToUpdate(cont);
        } catch (UnitOfWork.UnitOfWorkException e) {
            System.assertEquals('The list should be initialized and have at list one value!', e.getMessage());
        }
    }

    @IsTest
    static void testUpsertByOne() {
        testInsertByOne();
        UnitOfWork unitOfWork = new UnitOfWork(
                new Set<SObjectType>{
                        Account.SObjectType, Contact.SObjectType
                }
        );

        List<Account> accounts = [SELECT Name FROM Account];

        for (Account acc : accounts) {
            acc.Name = 'new';
            unitOfWork.addToUpsert(acc);
        }
        Contact cont;
        for (Integer i = 0; i < 50; i++) {
            cont = new Contact(LastName = 'new');
            unitOfWork.addToUpsert(cont);
        }
        unitOfWork.commitWork();

        System.assertEquals(5, [SELECT Id FROM Account WHERE Name = :'new'].size());
        System.assertEquals(5, [SELECT Id FROM Account].size());
        System.assertEquals(50, [SELECT Id FROM Contact WHERE LastName = :'new'].size());
        System.assertEquals(100, [SELECT Id FROM Contact].size());
    }

    @IsTest
    static void testUpsertByOneWithRelations() {
        testInsertByOne();
        UnitOfWork unitOfWork = new UnitOfWork(
                new Set<SObjectType>{
                        Account.SObjectType, Contact.SObjectType
                }
        );

        List<Account> accounts = [SELECT Name FROM Account];
        List<Contact> contacts = [SELECT Name FROM Contact];

        for (Account acc : accounts) {
            acc.Name = 'new';
            unitOfWork.addToUpsert(acc);
        }
        Contact c1;
        for (Integer i = 0; i < 50; i++) {
            c1 = new Contact(LastName = 'new');
            unitOfWork.addToUpsert(c1, Contact.AccountId, accounts[0]);
        }
        for (Contact c2 : contacts) {
            c2.LastName = 'old';
            unitOfWork.addToUpsert(c2, Contact.AccountId, accounts[1]);
        }

        unitOfWork.commitWork();

        System.assertEquals(5, [SELECT Id FROM Account WHERE Name = :'new'].size());
        System.assertEquals(5, [SELECT Id FROM Account].size());
        System.assertEquals(50, [SELECT Id FROM Contact WHERE LastName = 'new' AND AccountId = :accounts[0].Id].size());
        System.assertEquals(50, [SELECT Id FROM Contact WHERE LastName = 'old' AND AccountId = :accounts[1].Id].size());
        System.assertEquals(100, [SELECT Id FROM Contact].size());
    }

    @IsTest
    static void testUpsertByList() {
        testInsertByList();
        UnitOfWork unitOfWork = new UnitOfWork(
                new Set<SObjectType>{
                        Lead.SObjectType
                }
        );

        List<Lead> leads = [SELECT LastName, Company FROM Lead];
        for (Lead lead : leads) {
            lead.LastName = 'new';
        }
        leads.add(new Lead(LastName = 'old', Company = 'old'));
        unitOfWork.addToUpsert(leads);

        unitOfWork.commitWork();

        System.assertEquals(2, [SELECT Id FROM Lead WHERE LastName = :'new'].size());
        System.assertEquals(1, [SELECT Id FROM Lead WHERE LastName = :'old'].size());
        System.assertEquals(3, [SELECT Id FROM Lead].size());
    }

    @IsTest
    static void testUpsertByOneNullPointerException() {
        UnitOfWork unitOfWork = new UnitOfWork(
                new Set<SObjectType>{
                        Contact.SObjectType
                }
        );
        try {
            Contact cont;
            unitOfWork.addToUpsert(cont);
        } catch (UnitOfWork.UnitOfWorkException e) {
            System.assertEquals('SObject could not be null!', e.getMessage());
        }
    }

    @IsTest
    static void testUpsertByOneWithRelationsNullPointerException() {
        UnitOfWork unitOfWork = new UnitOfWork(
                new Set<SObjectType>{
                        Contact.SObjectType
                }
        );
        try {
            Contact cont;
            unitOfWork.addToUpsert(cont, Contact.AccountId, new Account());
        } catch (UnitOfWork.UnitOfWorkException e) {
            System.assertEquals('Child could not be null!', e.getMessage());
        }
    }

    @IsTest
    static void testUpsertByListNullPointerException() {
        UnitOfWork unitOfWork = new UnitOfWork(
                new Set<SObjectType>{
                        Contact.SObjectType
                }
        );
        try {
            List<Contact> cont;
            unitOfWork.addToUpsert(cont);
        } catch (UnitOfWork.UnitOfWorkException e) {
            System.assertEquals('The list should be initialized and have at list one value!', e.getMessage());
        }
    }

    @IsTest
    static void testDeleteByOne() {
        testInsertByOne();

        UnitOfWork unitOfWork = new UnitOfWork(
                new Set<SObjectType>{
                        Account.SObjectType, Contact.SObjectType
                }
        );

        List<Account> accounts = [SELECT Name FROM Account];
        List<Contact> contacts = [SELECT LastName FROM Contact];

        for (Integer i = 0; i < 25; i++) {
            unitOfWork.addToDelete(contacts[i]);
        }
        unitOfWork.addToDelete(accounts[0]);

        unitOfWork.commitWork();

        System.assertEquals(4, [SELECT Id FROM Account].size());
        System.assertEquals(25, [SELECT Id FROM Contact].size());
    }

    @IsTest
    static void testDeleteByList() {
        testInsertByOne();

        UnitOfWork unitOfWork = new UnitOfWork(
                new Set<SObjectType>{
                        Contact.SObjectType
                }
        );

        unitOfWork.addToDelete([SELECT LastName FROM Contact]);
        unitOfWork.commitWork();

        System.assertEquals(new List<Contact>(), [SELECT Id FROM Contact]);
    }

    @IsTest
    static void testDeleteByOneNullPointerException() {
        UnitOfWork unitOfWork = new UnitOfWork(
                new Set<SObjectType>{
                        Contact.SObjectType
                }
        );
        try {
            Contact cont;
            unitOfWork.addToDelete(cont);
        } catch (UnitOfWork.UnitOfWorkException e) {
            System.assertEquals('SObject could not be null!', e.getMessage());
        }
    }

    @IsTest
    static void testDeleteByListNullPointerException() {
        UnitOfWork unitOfWork = new UnitOfWork(
                new Set<SObjectType>{
                        Contact.SObjectType
                }
        );
        try {
            List<Contact> cont;
            unitOfWork.addToDelete(cont);
        } catch (UnitOfWork.UnitOfWorkException e) {
            System.assertEquals('The list should be initialized and have at list one value!', e.getMessage());
        }
    }

    @IsTest
    static void testRegisterNewRelations() {
        testInsertByOne();

        UnitOfWork unitOfWork = new UnitOfWork(
                new Set<SObjectType>{
                        Account.SObjectType, Contact.SObjectType
                }
        );

        List<Account> accounts = [SELECT Id FROM Account];
        List<Contact> contacts = [SELECT AccountId FROM Contact];

        for (Contact cont : contacts) {
            unitOfWork.registerRelations(cont, Contact.AccountId, accounts[0]);
        }
        unitOfWork.commitWork();

        System.assertEquals(50, [SELECT Id FROM Contact WHERE AccountId = :accounts[0].Id].size());
    }

    @IsTest
    static void testRegisterNewRelationsNullPointerException() {
        UnitOfWork unitOfWork = new UnitOfWork(
                new Set<SObjectType>{
                        Contact.SObjectType
                }
        );
        try {
            Contact cont;
            unitOfWork.registerRelations(cont, Contact.AccountId, new Account());
        } catch (UnitOfWork.UnitOfWorkException e) {
            System.assertEquals('Child could not be null!', e.getMessage());
        }
    }

    @IsTest
    static void testRegisterNewRelationsWrongFieldException() {
        UnitOfWork unitOfWork = new UnitOfWork(
                new Set<SObjectType>{
                        Contact.SObjectType
                }
        );
        try {
            unitOfWork.registerRelations(new Contact(), Opportunity.AccountId, new Contact());
        } catch (UnitOfWork.UnitOfWorkException e) {
            System.assertEquals('Wrong child field!', e.getMessage());
        }
    }

    @IsTest
    static void testRollBackException() {
        UnitOfWork unitOfWork = new UnitOfWork(
                new Set<SObjectType>{
                        Contact.SObjectType
                }
        );
        Boolean isExc = false;
        try {
            Contact cont = new Contact();
            unitOfWork.addToDelete(cont);
            unitOfWork.commitWork();
        } catch (Exception e) {
            isExc = true;
        }
        System.assertEquals(true, isExc, 'Error cause of invalid DML operation!');
    }

    @IsTest
    static void testNoMentionedException() {
        UnitOfWork unitOfWork = new UnitOfWork(
                new Set<SObjectType>{
                        Account.SObjectType
                }
        );
        try {
            Contact cont = new Contact(LastName = 'Contact');
            unitOfWork.isTypeNotMentioned(cont);
        } catch (UnitOfWork.UnitOfWorkException e) {
            System.assertEquals('SObjectType has not been mentioned!', e.getMessage());
        }
    }
}