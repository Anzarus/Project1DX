/**
 * Created by AntonAntoniuk on 23.09.2019.
 */

@IsTest
private class CheckJobStatusUtilTest {
    @IsTest
    static void testSuccess() {
        Test.setMock(HttpCalloutMock.class, new DropBoxConnectionTestMock());

        List<Remove_Job__c> openJobs = new List<Remove_Job__c>{
                new Remove_Job__c(JobId__c = 'dbjid:AABoqpEIEjq')
        };
        insert openJobs;
        List<File_Source__c> files = new List<File_Source__c>{
                new File_Source__c(Name = '/file (1).txt', Remove_Job__c = openJobs[0].Id),
                new File_Source__c(Name = '/file (3).txt', Remove_Job__c = openJobs[0].Id)
        };
        insert files;

        Test.startTest();
        CheckJobStatusUtil.checkDeletionStatus();
        Test.stopTest();

        Remove_Job__c removeJob = [
                SELECT Error_Message__c, Status__c
                FROM Remove_Job__c
                WHERE Id = :openJobs[0].Id
        ];

        System.assertEquals(null, removeJob.Error_Message__c);
        System.assertEquals('Success', removeJob.Status__c);
        System.assertEquals(new List<File_Source__c>(), [SELECT Id FROM File_Source__c]);
    }

    @IsTest
    static void testError() {
        Test.setMock(HttpCalloutMock.class, new DropBoxConnectionTestMock());

        List<Remove_Job__c> openJobs = new List<Remove_Job__c>{
                new Remove_Job__c(JobId__c = 'dbjid:AABoqpEIEjq1'),
                new Remove_Job__c(JobId__c = 'dbjid:other')
        };
        insert openJobs;
        List<File_Source__c> files = new List<File_Source__c>{
                new File_Source__c(Name = '/file.txt', Remove_Job__c = openJobs[1].Id),
                new File_Source__c(Name = '/file1.txt', Remove_Job__c = openJobs[1].Id),
                new File_Source__c(Name = '/file (2).txt', Remove_Job__c = openJobs[0].Id),
                new File_Source__c(Name = '/file (3).txt', Remove_Job__c = openJobs[0].Id)
        };
        insert files;

        Test.startTest();
        CheckJobStatusUtil.checkDeletionStatus();
        Test.stopTest();

        Map<Id, Remove_Job__c> openJobsByIds = new Map<Id, Remove_Job__c>(openJobs);
        List<Remove_Job__c> removeJobs = [
                SELECT Error_Message__c, Status__c
                FROM Remove_Job__c
                WHERE Id IN :openJobsByIds.keySet()
        ];

        System.assertEquals('ERROR! Some files has not been deleted in DropBox, ' +
                'please pay attention! But this files has been deleted: ' +
                '(/file (2).txt)', removeJobs[0].Error_Message__c);
        System.assertEquals('Failed', removeJobs[0].Status__c);
        System.assertEquals(null, removeJobs[1].Error_Message__c);
        System.assertEquals('New', removeJobs[1].Status__c);
        System.assertEquals(files[0], [SELECT Name, Remove_Job__c, Id FROM File_Source__c WHERE Id = :files[0].Id]);
        System.assertEquals(files[1], [SELECT Name, Remove_Job__c, Id FROM File_Source__c WHERE Id = :files[1].Id]);
    }
}