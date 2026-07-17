@isTest
private class StaleApplicationSchedulerTest {

    @isTest
    static void testScheduler() {

        Test.startTest();

        String cron = '0 0 0 * * ?';

        System.schedule(
            'Test Scheduler',
            cron,
            new StaleApplicationScheduler()
        );

        Test.stopTest();

        CronTrigger job = [

            SELECT Id,
                   CronExpression,
                   State

            FROM CronTrigger

            LIMIT 1
        ];

        System.assertEquals(
            'WAITING',
            job.State
        );

    }

}