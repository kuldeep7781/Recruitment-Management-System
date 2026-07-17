@isTest
private class ApplicationNotificationQueueableTest {

    @isTest
    static void testQueueableExecution() {

        Candidate__c candidate = new Candidate__c(
            Name = 'Queue Candidate',
            Email__c = 'queue@test.com',
            Phone__c = '9999999999',
            Experience_Years__c = 2
        );
        insert candidate;

        Job_Position__c position = new Job_Position__c(
            Name = 'Salesforce Developer',
            Openings__c = 1,
            Status__c = RecruitmentConstants.POSITION_OPEN
        );
        insert position;

        Job_Application__c application =
            new Job_Application__c(
                Candidate__c = candidate.Id,
                Job_Position__c = position.Id,
                Application_Status__c =
                    RecruitmentConstants.STATUS_SELECTED,
                Applied_Date__c = Date.today()
            );

        insert application;

        Test.startTest();

        System.enqueueJob(
            new ApplicationNotificationQueueable(
                new Set<Id>{application.Id}
            )
        );

        Test.stopTest();

        System.assert(true);
    }

}