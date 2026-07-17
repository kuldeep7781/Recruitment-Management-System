@isTest
private class RecruitmentServiceTest {

    @TestSetup
    static void setupTestData() {
        Candidate__c candidate = new Candidate__c(
            Name     = 'Test Candidate',
            Email__c = 'test@example.com',
            Phone__c = '9876543210'
        );
        insert candidate;

        Job_Position__c position = new Job_Position__c(
            Name        = 'Salesforce Developer',
            Openings__c = 2,
            Status__c   = 'Open'
        );
        insert position;

        Job_Application__c application = new Job_Application__c(
            Candidate__c          = candidate.Id,
            Job_Position__c       = position.Id,
            Application_Status__c = 'Interview Scheduled',
            Applied_Date__c       = Date.today()
        );
        insert application;
    }

    @isTest
    static void testInterviewCleared() {
        Job_Application__c app = [SELECT Id FROM Job_Application__c LIMIT 1];

        Interview__c interview = new Interview__c(
            Job_Application__c  = app.Id,
            Interview_Date__c   = DateTime.now().addDays(1),
            Interview_Result__c = 'Cleared'
        );

        Test.startTest();
        insert interview;
        Test.stopTest();

        Job_Application__c updatedApp = [
            SELECT Application_Status__c
            FROM Job_Application__c
            WHERE Id = :app.Id
        ];

        System.assertEquals('Shortlisted', updatedApp.Application_Status__c, 'Should be Shortlisted');
    }

    @isTest
    static void testInterviewRejected() {
        Job_Application__c app = [SELECT Id FROM Job_Application__c LIMIT 1];

        Interview__c interview = new Interview__c(
            Job_Application__c  = app.Id,
            Interview_Date__c   = DateTime.now().addDays(1),
            Interview_Result__c = 'Rejected'
        );

        Test.startTest();
        insert interview;
        Test.stopTest();

        Job_Application__c updatedApp = [
            SELECT Application_Status__c
            FROM Job_Application__c
            WHERE Id = :app.Id
        ];

        System.assertEquals('Rejected', updatedApp.Application_Status__c, 'Should be Rejected');
    }

    @isTest
    static void testInterviewOnHold() {
        Job_Application__c app = [SELECT Id FROM Job_Application__c LIMIT 1];

        Interview__c interview = new Interview__c(
            Job_Application__c  = app.Id,
            Interview_Date__c   = DateTime.now().addDays(1),
            Interview_Result__c = 'On Hold'
        );

        Test.startTest();
        insert interview;
        Test.stopTest();

        Job_Application__c updatedApp = [
            SELECT Application_Status__c
            FROM Job_Application__c
            WHERE Id = :app.Id
        ];

        System.assertEquals('Screening', updatedApp.Application_Status__c, 'Should be Screening');
    }

    @isTest
    static void testInterviewResultUpdate() {
        Job_Application__c app = [SELECT Id FROM Job_Application__c LIMIT 1];

        Interview__c interview = new Interview__c(
            Job_Application__c  = app.Id,
            Interview_Date__c   = DateTime.now().addDays(1),
            Interview_Result__c = 'Cleared'
        );
        insert interview;

        Test.startTest();
        interview.Interview_Result__c = 'Rejected';
        update interview;
        Test.stopTest();

        Job_Application__c updatedApp = [
            SELECT Application_Status__c
            FROM Job_Application__c
            WHERE Id = :app.Id
        ];

        System.assertEquals('Rejected', updatedApp.Application_Status__c, 'Should be Rejected');
    }

    @isTest
    static void testBulkInterviews() {
        Job_Application__c app = [SELECT Id FROM Job_Application__c LIMIT 1];

        List<Interview__c> interviews = new List<Interview__c>();
        for (Integer i = 0; i < 200; i++) {
            interviews.add(new Interview__c(
                Job_Application__c  = app.Id,
                Interview_Date__c   = DateTime.now().addDays(1),
                Interview_Result__c = 'Cleared'
            ));
        }

        Test.startTest();
        insert interviews;
        Test.stopTest();

        Job_Application__c updatedApp = [
            SELECT Application_Status__c
            FROM Job_Application__c
            WHERE Id = :app.Id
        ];

        System.assertEquals('Shortlisted', updatedApp.Application_Status__c, 'Should be Shortlisted');
    }
}