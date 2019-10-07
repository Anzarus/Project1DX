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
    static void testInsertOneNullPointerException() {
        UnitOfWork unitOfWork = new UnitOfWork(
                new Set<SObjectType>{
                        Contact.SObjectType
                }
        );
        try {
            Contact cont;
            unitOfWork.addToInsert(cont);
        } catch (Exception e) {
            System.assertEquals(e.getMessage(), e.getMessage());
        }
    }

    @IsTest
    static void testInsertListNullPointerException() {
        UnitOfWork unitOfWork = new UnitOfWork(
                new Set<SObjectType>{
                        Contact.SObjectType
                }
        );
        try {
            List<Contact> cont;
            unitOfWork.addToInsert(cont);
        } catch (Exception e) {
            System.assertEquals(e.getMessage(), e.getMessage());
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
    static void testUpdateOneNullPointerException() {
        UnitOfWork unitOfWork = new UnitOfWork(
                new Set<SObjectType>{
                        Contact.SObjectType
                }
        );
        try {
            Contact cont;
            unitOfWork.addToUpdate(cont);
        } catch (Exception e) {
            System.assertEquals(e.getMessage(), e.getMessage());
        }
    }

    @IsTest
    static void testUpdateListNullPointerException() {
        UnitOfWork unitOfWork = new UnitOfWork(
                new Set<SObjectType>{
                        Contact.SObjectType
                }
        );
        try {
            List<Contact> cont;
            unitOfWork.addToUpdate(cont);
        } catch (Exception e) {
            System.assertEquals(e.getMessage(), e.getMessage());
        }
    }
/*
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
    static void testUpsertOneNullPointerException() {
        UnitOfWork unitOfWork = new UnitOfWork(
                new Set<SObjectType>{
                        Contact.SObjectType
                }
        );
        try {
            Contact cont;
            unitOfWork.addToUpsert(cont);
        } catch (Exception e) {
            System.assertEquals(e.getMessage(), e.getMessage());
        }
    }

    @IsTest
    static void testUpsertListNullPointerException() {
        UnitOfWork unitOfWork = new UnitOfWork(
                new Set<SObjectType>{
                        Contact.SObjectType
                }
        );
        try {
            List<Contact> cont;
            unitOfWork.addToUpsert(cont);
        } catch (Exception e) {
            System.assertEquals(e.getMessage(), e.getMessage());
        }
    }*/

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
    static void testDeleteOneNullPointerException() {
        UnitOfWork unitOfWork = new UnitOfWork(
                new Set<SObjectType>{
                        Contact.SObjectType
                }
        );
        try {
            Contact cont;
            unitOfWork.addToDelete(cont);
        } catch (Exception e) {
            System.assertEquals(e.getMessage(), e.getMessage());
        }
    }

    @IsTest
    static void testDeleteListNullPointerException() {
        UnitOfWork unitOfWork = new UnitOfWork(
                new Set<SObjectType>{
                        Contact.SObjectType
                }
        );
        try {
            List<Contact> cont;
            unitOfWork.addToDelete(cont);
        } catch (Exception e) {
            System.assertEquals(e.getMessage(), e.getMessage());
        }
    }

    @IsTest
    static void testRollBackException() {
        UnitOfWork unitOfWork = new UnitOfWork(
                new Set<SObjectType>{
                        Contact.SObjectType
                }
        );
        try {
            Contact cont = new Contact();
            unitOfWork.addToDelete(cont);
            unitOfWork.commitWork();
        } catch (Exception e) {
            System.assertEquals(e.getMessage(), e.getMessage());
        }
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
        } catch (Exception e) {
            System.assertEquals(e.getMessage(), e.getMessage());
        }
    }
}