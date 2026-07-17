public with sharing class CandidateDashboardController {

    
    public class ApplicationWrapper {

        @AuraEnabled public String applicationNumber;
        @AuraEnabled public String positionName;
        @AuraEnabled public String status;
        @AuraEnabled public Date appliedDate;

    }

    
    public class CandidateWrapper {

        @AuraEnabled public Id candidateId;
        @AuraEnabled public String candidateName;
        @AuraEnabled public String email;
        @AuraEnabled public String phone;
        @AuraEnabled public String skills;
        @AuraEnabled public Decimal experience;

        @AuraEnabled
        public List<ApplicationWrapper> applications =
            new List<ApplicationWrapper>();
    }

    
    @AuraEnabled(cacheable=true)
    public static List<CandidateWrapper> getCandidates() {

        try {

            List<CandidateWrapper> response =
                new List<CandidateWrapper>();

            List<Candidate__c> candidates = [

                SELECT
                    Id,
                    Name,
                    Email__c,
                    Phone__c,
                    Skills__c,
                    Experience_Years__c,

                    (
                        SELECT
                            Id,
                            Name,
                            Application_Status__c,
                            Applied_Date__c,
                            Job_Position__r.Name
                        FROM Job_Applications__r
                        ORDER BY Applied_Date__c DESC
                    )

                FROM Candidate__c
                ORDER BY Name

            ];

            for (Candidate__c candidate : candidates) {

                CandidateWrapper cw =
                    new CandidateWrapper();

                cw.candidateId = candidate.Id;
                cw.candidateName = candidate.Name;
                cw.email = candidate.Email__c;
                cw.phone = candidate.Phone__c;
                cw.skills = candidate.Skills__c;
                cw.experience = candidate.Experience_Years__c;

                for (Job_Application__c app :
                    candidate.Job_Applications__r) {

                    ApplicationWrapper aw =
                        new ApplicationWrapper();

                    aw.applicationNumber = app.Name;
                    aw.status = app.Application_Status__c;
                    aw.appliedDate = app.Applied_Date__c;

                    if (app.Job_Position__r != null) {
                        aw.positionName =
                            app.Job_Position__r.Name;
                    }

                    cw.applications.add(aw);
                }

                response.add(cw);

            }

            return response;

        }
        catch (Exception ex) {

            throw new AuraHandledException(
                'Unable to load candidates. ' +
                ex.getMessage()
            );

        }

    }

    
    @AuraEnabled(cacheable=true)
    public static List<CandidateWrapper> searchCandidates(String keyword) {

        try {

            List<CandidateWrapper> response =
                new List<CandidateWrapper>();

            if (String.isBlank(keyword)) {
                return getCandidates();
            }

            List<List<SObject>> searchResults = [

                FIND :keyword IN ALL FIELDS

                RETURNING Candidate__c(

                    Id,
                    Name,
                    Email__c,
                    Phone__c,
                    Skills__c,
                    Experience_Years__c

                )

            ];

            List<Candidate__c> candidates =
                (List<Candidate__c>) searchResults[0];

            if (candidates.isEmpty()) {
                return response;
            }

            Set<Id> candidateIds = new Set<Id>();

            for (Candidate__c c : candidates) {
                candidateIds.add(c.Id);
            }

            Map<Id, List<Job_Application__c>> applicationMap =
                new Map<Id, List<Job_Application__c>>();

            for (Job_Application__c app : [

                SELECT
                    Id,
                    Name,
                    Candidate__c,
                    Application_Status__c,
                    Applied_Date__c,
                    Job_Position__r.Name

                FROM Job_Application__c

                WHERE Candidate__c IN :candidateIds

                ORDER BY Applied_Date__c DESC

            ]) {

                if (!applicationMap.containsKey(app.Candidate__c)) {

                    applicationMap.put(
                        app.Candidate__c,
                        new List<Job_Application__c>()
                    );

                }

                applicationMap.get(app.Candidate__c).add(app);

            }

            for (Candidate__c candidate : candidates) {

                CandidateWrapper cw =
                    new CandidateWrapper();

                cw.candidateId = candidate.Id;
                cw.candidateName = candidate.Name;
                cw.email = candidate.Email__c;
                cw.phone = candidate.Phone__c;
                cw.skills = candidate.Skills__c;
                cw.experience = candidate.Experience_Years__c;

                if (applicationMap.containsKey(candidate.Id)) {

                    for (Job_Application__c app :
                        applicationMap.get(candidate.Id)) {

                        ApplicationWrapper aw =
                            new ApplicationWrapper();

                        aw.applicationNumber = app.Name;

                        if (app.Job_Position__r != null) {
                            aw.positionName =
                                app.Job_Position__r.Name;
                        }

                        aw.status =
                            app.Application_Status__c;

                        aw.appliedDate =
                            app.Applied_Date__c;

                        cw.applications.add(aw);

                    }

                }

                response.add(cw);

            }

            return response;

        }
        catch (Exception ex) {

            throw new AuraHandledException(
                'Unable to search candidates. ' +
                ex.getMessage()
            );

        }

    }

}