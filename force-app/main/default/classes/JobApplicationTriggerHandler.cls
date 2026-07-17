public with sharing class JobApplicationTriggerHandler {

    
    public static void handleBeforeInsert(List<Job_Application__c> newApplications) {

        JobApplicationService.setDefaultAppliedDate(newApplications);
    }

    
    public static void handleAfterUpdate(
        List<Job_Application__c> newApplications,
        Map<Id, Job_Application__c> oldMap
    ) {

        List<Job_Application__c> changedApplications = new List<Job_Application__c>();

        for (Job_Application__c app : newApplications) {

            Job_Application__c oldApp = oldMap.get(app.Id);

            if (oldApp != null &&
                app.Application_Status__c != oldApp.Application_Status__c) {

                changedApplications.add(app);
            }
        }

        if (!changedApplications.isEmpty()) {
            JobApplicationService.handleStatusChange(changedApplications);
        }
    }
}