/**
 * Created by AntonAntoniuk on 23.09.2019.
 */

@IsTest
private class CheckJobStatusTest {

    private static String CRON_EPR = '0 0 0 20 5 ? 2021';

    @IsTest
    static void testSuccess() {
        Test.startTest();
        String jobId = System.schedule('Start schedule', CRON_EPR, new CheckJobStatus());

        CronTrigger cronTrigger = [
                SELECT NextFireTime
                FROM CronTrigger
                WHERE Id = :jobId
        ];

        System.assertEquals('2021-05-20 00:00:00', String.valueOf(cronTrigger.NextFireTime));
        Test.stopTest();
    }
}