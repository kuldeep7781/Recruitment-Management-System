@isTest
private class JobApplicationServiceTest {

    @TestSetup
    static void setupTestData() {

        Candidate__c candidate1 = new Candidate__c(
            Name = 'Candidate 1',
            Email__c = 'candidate1@test.com',
            Phone__c = '9876543210'
        );

        Candidate__c candidate2 = new Candidate__c(
            Name = 'Candidate 2',
            Email__c = 'candidate2@test.com',
            Phone__c = '9876543211'
        );

        insert new List<Candidate__c>{candidate1, candidate2};

        Job_Position__c position = new Job_Position__c(
            Name = 'Salesforce Developer',
            Openings__c = 2,
            Status__c = RecruitmentConstants.POSITION_OPEN
        );

        insert position;

        Job_Application__c app1 = new Job_Application__c(
            Candidate__c = candidate1.Id,
            Job_Position__c = position.Id,
            Application_Status__c = RecruitmentConstants.STATUS_APPLIED
        );

        Job_Application__c app2 = new Job_Application__c(
            Candidate__c = candidate2.Id,
            Job_Position__c = position.Id,
            Application_Status__c = RecruitmentConstants.STATUS_APPLIED
        );

        insert new List<Job_Application__c>{app1, app2};
    }

    @isTest
    static void testDefaultAppliedDate() {

        Candidate__c candidate = new Candidate__c(
            Name = 'New Candidate',
            Email__c = 'new@test.com',
            Phone__c = '9999999999'
        );

        insert candidate;

        Job_Position__c position =
            [SELECT Id FROM Job_Position__c LIMIT 1];

        Job_Application__c app = new Job_Application__c(
            Candidate__c = candidate.Id,
            Job_Position__c = position.Id,
            Application_Status__c = RecruitmentConstants.STATUS_APPLIED
        );

        Test.startTest();
        insert app;
        Test.stopTest();

        Job_Application__c insertedApp =
        [
            SELECT Applied_Date__c
            FROM Job_Application__c
            WHERE Id = :app.Id
        ];

        System.assertEquals(
            Date.today(),
            insertedApp.Applied_Date__c,
            'Applied Date should default to today.'
        );
    }

    @isTest
    static void testClosePositionWhenFilled() {

        List<Job_Application__c> applications =
        [
            SELECT Id, Application_Status__c
            FROM Job_Application__c
        ];

        Test.startTest();

        for(Job_Application__c app : applications){
            app.Application_Status__c =
                RecruitmentConstants.STATUS_SELECTED;
        }

        update applications;

        Test.stopTest();

        Job_Position__c position =
        [
            SELECT Status__c
            FROM Job_Position__c
            LIMIT 1
        ];

        System.assertEquals(
            RecruitmentConstants.POSITION_CLOSED,
            position.Status__c,
            'Position should close when openings are filled.'
        );
    }

    @isTest
    static void testPositionRemainsOpen() {

        Job_Application__c app =
        [
            SELECT Id, Application_Status__c
            FROM Job_Application__c
            LIMIT 1
        ];

        Test.startTest();

        app.Application_Status__c =
            RecruitmentConstants.STATUS_SELECTED;

        update app;

        Test.stopTest();

        Job_Position__c position =
        [
            SELECT Status__c
            FROM Job_Position__c
            LIMIT 1
        ];

        System.assertEquals(
            RecruitmentConstants.POSITION_OPEN,
            position.Status__c,
            'Position should remain open.'
        );
    }

    @isTest
    static void testBulkUpdateApplications() {

        List<Job_Application__c> applications =
        [
            SELECT Id, Application_Status__c
            FROM Job_Application__c
        ];

        Test.startTest();

        for(Job_Application__c app : applications){
            app.Application_Status__c =
                RecruitmentConstants.STATUS_SELECTED;
        }

        update applications;

        Test.stopTest();

        Job_Position__c position =
        [
            SELECT Status__c
            FROM Job_Position__c
            LIMIT 1
        ];

        System.assertEquals(
            RecruitmentConstants.POSITION_CLOSED,
            position.Status__c
        );
    }
}