@isTest
public class RecruitmentTestDataFactory {

    public static Candidate__c createCandidate() {
        Candidate__c candidate = new Candidate__c(
            Name = 'Test Candidate',
            Email__c = 'test@example.com',
            Phone__c = '9876543210',
            Experience_Years__c = 2
        );
        insert candidate;
        return candidate;
    }

    public static Job_Position__c createJobPosition(Integer openings) {
        Job_Position__c position = new Job_Position__c(
            Name = 'Salesforce Developer',
            Openings__c = openings,
            Status__c = RecruitmentConstants.POSITION_OPEN
        );
        insert position;
        return position;
    }

    public static Job_Application__c createJobApplication(
        Id candidateId,
        Id positionId,
        String status
    ) {
        Job_Application__c application = new Job_Application__c(
            Candidate__c = candidateId,
            Job_Position__c = positionId,
            Application_Status__c = status,
            Applied_Date__c = Date.today()
        );
        insert application;
        return application;
    }

    public static Interview__c createInterview(
        Id applicationId,
        String result
    ) {
        Interview__c interview = new Interview__c(
            Job_Application__c = applicationId,
            Interview_Date__c = DateTime.now().addDays(1),
            Interview_Result__c = result
        );
        insert interview;
        return interview;
    }
}