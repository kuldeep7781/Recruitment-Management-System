@isTest
private class CandidateDashboardControllerTest {

    @TestSetup
    static void setupData() {

        Candidate__c candidate = new Candidate__c(
            Name = 'John Doe',
            Email__c = 'john@test.com',
            Phone__c = '9876543210',
            Skills__c = 'Apex,LWC',
            Experience_Years__c = 2
        );
        insert candidate;

        Job_Position__c position = new Job_Position__c(
            Name = 'Salesforce Developer',
            Openings__c = 2,
            Status__c = RecruitmentConstants.POSITION_OPEN
        );
        insert position;

        Job_Application__c application = new Job_Application__c(
            Candidate__c = candidate.Id,
            Job_Position__c = position.Id,
            Application_Status__c = RecruitmentConstants.STATUS_APPLIED,
            Applied_Date__c = Date.today()
        );
        insert application;
    }

    @isTest
    static void testGetCandidates() {

        Test.startTest();

        List<CandidateDashboardController.CandidateWrapper> result =
            CandidateDashboardController.getCandidates();

        Test.stopTest();

        System.assert(!result.isEmpty(), 'Candidates should be returned.');

        CandidateDashboardController.CandidateWrapper candidate =
            result[0];

        System.assertEquals('John Doe', candidate.candidateName);
        System.assertEquals('john@test.com', candidate.email);
        System.assertEquals('9876543210', candidate.phone);
        System.assertEquals('Apex,LWC', candidate.skills);
        System.assertEquals(2, candidate.experience);

        System.assertEquals(
            1,
            candidate.applications.size(),
            'Candidate should have one application.'
        );

        CandidateDashboardController.ApplicationWrapper application =
            candidate.applications[0];

        System.assertEquals(
            'Salesforce Developer',
            application.positionName
        );

        System.assertEquals(
            RecruitmentConstants.STATUS_APPLIED,
            application.status
        );
    }

    @isTest
    static void testNoCandidates() {

        delete [SELECT Id FROM Job_Application__c];
        delete [SELECT Id FROM Candidate__c];

        Test.startTest();

        List<CandidateDashboardController.CandidateWrapper> result =
            CandidateDashboardController.getCandidates();

        Test.stopTest();

        System.assertEquals(
            0,
            result.size(),
            'No candidates should be returned.'
        );
    }
}