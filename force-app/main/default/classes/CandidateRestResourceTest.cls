@isTest
private class CandidateRestResourceTest {

    @TestSetup
    static void setupData() {

        Job_Position__c position = new Job_Position__c(
            Name = 'Salesforce Developer',
            Openings__c = 2,
            Status__c = RecruitmentConstants.POSITION_OPEN
        );
        insert position;
    }

    @isTest
    static void testCreateCandidateSuccess() {

        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();

        req.requestURI = '/services/apexrest/candidate';
        req.httpMethod = 'POST';

        req.requestBody = Blob.valueOf(
            '{"name":"John Doe",' +
            '"email":"john@test.com",' +
            '"phone":"9876543210",' +
            '"skills":"Apex,LWC",' +
            '"experience":2,' +
            '"jobPosition":"Salesforce Developer"}'
        );

        RestContext.request = req;
        RestContext.response = res;

        Test.startTest();

        CandidateRestResource.CandidateResponse response =
            CandidateRestResource.createCandidate();

        Test.stopTest();

        System.assertEquals(true, response.success);
        System.assertEquals('Candidate created successfully.', response.message);
        System.assertNotEquals(null, response.candidateId);
        System.assertNotEquals(null, response.applicationId);

        Candidate__c candidate = [
            SELECT Id, Email__c
            FROM Candidate__c
            WHERE Email__c = 'john@test.com'
            LIMIT 1
        ];

        System.assertEquals('john@test.com', candidate.Email__c);
    }

    @isTest
    static void testDuplicateCandidate() {

        Candidate__c candidate = new Candidate__c(
            Name = 'Existing Candidate',
            Email__c = 'duplicate@test.com',
            Phone__c = '9999999999',
            Experience_Years__c = 2
        );
        insert candidate;

        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();

        req.requestURI = '/services/apexrest/candidate';
        req.httpMethod = 'POST';

        req.requestBody = Blob.valueOf(
            '{"name":"John Doe",' +
            '"email":"duplicate@test.com",' +
            '"phone":"9876543210",' +
            '"skills":"Apex",' +
            '"experience":2,' +
            '"jobPosition":"Salesforce Developer"}'
        );

        RestContext.request = req;
        RestContext.response = res;

        Test.startTest();

        CandidateRestResource.CandidateResponse response =
            CandidateRestResource.createCandidate();

        Test.stopTest();

        System.assertEquals(false, response.success);
        System.assertEquals(
            'Candidate already exists with this email.',
            response.message
        );
    }

    @isTest
    static void testJobPositionNotFound() {

        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();

        req.requestURI = '/services/apexrest/candidate';
        req.httpMethod = 'POST';

        req.requestBody = Blob.valueOf(
            '{"name":"John",' +
            '"email":"john2@test.com",' +
            '"phone":"9876543210",' +
            '"skills":"Apex",' +
            '"experience":2,' +
            '"jobPosition":"Python Developer"}'
        );

        RestContext.request = req;
        RestContext.response = res;

        Test.startTest();

        CandidateRestResource.CandidateResponse response =
            CandidateRestResource.createCandidate();

        Test.stopTest();

        System.assertEquals(false, response.success);
        System.assertEquals(
            'Job Position not found.',
            response.message
        );
    }

    @isTest
    static void testMissingRequiredFields() {

        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();

        req.requestURI = '/services/apexrest/candidate';
        req.httpMethod = 'POST';

        req.requestBody = Blob.valueOf(
            '{"name":"","email":"","jobPosition":""}'
        );

        RestContext.request = req;
        RestContext.response = res;

        Test.startTest();

        CandidateRestResource.CandidateResponse response =
            CandidateRestResource.createCandidate();

        Test.stopTest();

        System.assertEquals(false, response.success);
        System.assertEquals(
            'Name, Email and Job Position are required.',
            response.message
        );
    }
}