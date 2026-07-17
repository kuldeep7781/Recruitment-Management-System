@isTest
private class StaleApplicationBatchTest {

    @TestSetup
    static void setupData() {

        Candidate__c candidate = new Candidate__c(
            Name = 'Batch Candidate',
            Email__c = 'batch@test.com',
            Phone__c = '9876543210',
            Experience_Years__c = 2
        );
        insert candidate;

        Job_Position__c position = new Job_Position__c(
            Name = 'Salesforce Developer',
            Openings__c = 2,
            Status__c = RecruitmentConstants.POSITION_OPEN
        );
        insert position;

        
        Job_Application__c oldApplication = new Job_Application__c(
            Candidate__c = candidate.Id,
            Job_Position__c = position.Id,
            Applied_Date__c = Date.today().addDays(-35),
            Application_Status__c = RecruitmentConstants.STATUS_APPLIED
        );

        
        Job_Application__c newApplication = new Job_Application__c(
            Candidate__c = candidate.Id,
            Job_Position__c = position.Id,
            Applied_Date__c = Date.today().addDays(-5),
            Application_Status__c = RecruitmentConstants.STATUS_APPLIED
        );

        insert new List<Job_Application__c>{
            oldApplication,
            newApplication
        };
    }

    @isTest
    static void testBatchUpdatesOldApplications() {

        Test.startTest();

        Database.executeBatch(new StaleApplicationBatch(), 200);

        Test.stopTest();

        List<Job_Application__c> applications = [
            SELECT Applied_Date__c,
                   Application_Status__c
            FROM Job_Application__c
            ORDER BY Applied_Date__c
        ];

        System.assertEquals(
            RecruitmentConstants.STATUS_WITHDRAWN,
            applications[0].Application_Status__c,
            'Old application should become Withdrawn.'
        );

        System.assertEquals(
            RecruitmentConstants.STATUS_APPLIED,
            applications[1].Application_Status__c,
            'Recent application should remain Applied.'
        );
    }

}