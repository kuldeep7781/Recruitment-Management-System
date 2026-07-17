public with sharing class RecruitmentService {

    public static void updateApplicationStatus(List<Interview__c> interviews) {

        Set<Id> applicationIds = new Set<Id>();

        for (Interview__c interview : interviews) {

            if (interview.Job_Application__c != null) {
                applicationIds.add(interview.Job_Application__c);
            }

        }

        if (applicationIds.isEmpty()) {
            return;
        }

        Map<Id, Job_Application__c> applicationMap =
            new Map<Id, Job_Application__c>(
                [
                    SELECT Id,
                           Application_Status__c
                    FROM Job_Application__c
                    WHERE Id IN :applicationIds
                ]
            );

        for (Interview__c interview : interviews) {

            if (interview.Job_Application__c == null) {
                continue;
            }

            Job_Application__c app =
                applicationMap.get(interview.Job_Application__c);

            if (app == null) {
                continue;
            }

            if (interview.Interview_Result__c ==
                RecruitmentConstants.RESULT_PENDING) {

                app.Application_Status__c =
                    RecruitmentConstants.STATUS_INTERVIEW_SCHEDULED;

            }
            else if (interview.Interview_Result__c ==
                     RecruitmentConstants.RESULT_CLEARED) {

                app.Application_Status__c =
                    RecruitmentConstants.STATUS_SHORTLISTED;

            }
            else if (interview.Interview_Result__c ==
                     RecruitmentConstants.RESULT_REJECTED) {

                app.Application_Status__c =
                    RecruitmentConstants.STATUS_REJECTED;

            }
            else if (interview.Interview_Result__c ==
                     RecruitmentConstants.RESULT_ON_HOLD) {

                app.Application_Status__c =
                    RecruitmentConstants.STATUS_SCREENING;

            }

        }

        if (!applicationMap.isEmpty()) {
            update applicationMap.values();
        }

    }

}