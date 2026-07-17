@RestResource(urlMapping='/candidate/*')
global with sharing class CandidateRestResource {

    
    global class CandidateRequest {

        public String name;
        public String email;
        public String phone;
        public String skills;
        public Decimal experience;
        public String jobPosition;

    }

    
    global class CandidateResponse {

        public Boolean success;
        public String message;
        public Id candidateId;
        public Id applicationId;

    }

    @HttpPost
    global static CandidateResponse createCandidate() {

        CandidateResponse response = new CandidateResponse();

        try {

            RestRequest request = RestContext.request;

            if (request == null ||
                request.requestBody == null ||
                String.isBlank(request.requestBody.toString())) {

                RestContext.response.statusCode = 400;

                response.success = false;
                response.message = 'Request body cannot be empty.';

                return response;
            }

            CandidateRequest candidateRequest =
                (CandidateRequest) JSON.deserialize(
                    request.requestBody.toString(),
                    CandidateRequest.class
                );

            
            if (String.isBlank(candidateRequest.name) ||
                String.isBlank(candidateRequest.email) ||
                String.isBlank(candidateRequest.jobPosition)) {

                RestContext.response.statusCode = 400;

                response.success = false;
                response.message =
                    'Name, Email and Job Position are required.';

                return response;
            }

            
            List<Candidate__c> existingCandidates = [

                SELECT Id
                FROM Candidate__c
                WHERE Email__c = :candidateRequest.email
                LIMIT 1

            ];

            if (!existingCandidates.isEmpty()) {

                RestContext.response.statusCode = 409;

                response.success = false;
                response.message =
                    'Candidate already exists with this email.';

                return response;
            }

            
            List<Job_Position__c> positions = [

                SELECT Id,
                       Status__c
                FROM Job_Position__c
                WHERE Name = :candidateRequest.jobPosition
                LIMIT 1

            ];

            if (positions.isEmpty()) {

                RestContext.response.statusCode = 404;

                response.success = false;
                response.message = 'Job Position not found.';

                return response;
            }

            Job_Position__c position = positions[0];

            if (position.Status__c !=
                RecruitmentConstants.POSITION_OPEN) {

                RestContext.response.statusCode = 400;

                response.success = false;
                response.message = 'Job Position is not open.';

                return response;
            }

           
            Candidate__c candidate = new Candidate__c(

                Name = candidateRequest.name,
                Email__c = candidateRequest.email,
                Phone__c = candidateRequest.phone,
                Skills__c = candidateRequest.skills,
                Experience_Years__c =
                    candidateRequest.experience

            );

            insert candidate;

            
            Job_Application__c application =
                new Job_Application__c(

                    Candidate__c = candidate.Id,
                    Job_Position__c = position.Id,
                    Application_Status__c =
                        RecruitmentConstants.STATUS_APPLIED,
                    Applied_Date__c = Date.today()

                );

            insert application;

            RestContext.response.statusCode = 201;

            response.success = true;
            response.message =
                'Candidate created successfully.';
            response.candidateId = candidate.Id;
            response.applicationId = application.Id;

            return response;

        }
        catch (Exception ex) {

            RestContext.response.statusCode = 500;

            response.success = false;
            response.message =
                'An unexpected error occurred while creating the candidate.';

            return response;

        }

    }

}