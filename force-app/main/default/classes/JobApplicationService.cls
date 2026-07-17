public with sharing class JobApplicationService {

    
    public static void setDefaultAppliedDate(List<Job_Application__c> applications) {

        for (Job_Application__c app : applications) {

            if (app.Applied_Date__c == null) {
                app.Applied_Date__c = Date.today();
            }
        }
    }

    
    public static void handleStatusChange(List<Job_Application__c> applications) {

        Set<Id> positionIds = new Set<Id>();

        for (Job_Application__c app : applications) {

            if (app.Application_Status__c == RecruitmentConstants.STATUS_SELECTED
                && app.Job_Position__c != null) {

                positionIds.add(app.Job_Position__c);
            }
        }

        if (positionIds.isEmpty()) {
            return;
        }

        Map<Id, Job_Position__c> positionMap =
            new Map<Id, Job_Position__c>(
                [
                    SELECT Id,
                           Openings__c,
                           Status__c
                    FROM Job_Position__c
                    WHERE Id IN :positionIds
                ]
            );

        List<AggregateResult> results = [

            SELECT Job_Position__c positionId,
                   COUNT(Id) selectedCount

            FROM Job_Application__c

            WHERE Job_Position__c IN :positionIds
            AND Application_Status__c = :RecruitmentConstants.STATUS_SELECTED

            GROUP BY Job_Position__c
        ];

        List<Job_Position__c> positionsToUpdate =
            new List<Job_Position__c>();

        for (AggregateResult result : results) {

            Id positionId = (Id) result.get('positionId');

            Integer selectedCount =
                (Integer) result.get('selectedCount');

            Job_Position__c position =
                positionMap.get(positionId);

            if (position != null &&
                selectedCount >= position.Openings__c &&
                position.Status__c != RecruitmentConstants.POSITION_CLOSED) {

                position.Status__c =
                    RecruitmentConstants.POSITION_CLOSED;

                positionsToUpdate.add(position);
            }
        }

        if (!positionsToUpdate.isEmpty()) {
            update positionsToUpdate;
        }

        Set<Id> selectedApplicationIds = new Set<Id>();

        for (Job_Application__c app : applications) {

            if (app.Application_Status__c ==
                RecruitmentConstants.STATUS_SELECTED) {

                selectedApplicationIds.add(app.Id);
            }
        }

        if (!selectedApplicationIds.isEmpty()) {

            System.enqueueJob(
                new ApplicationNotificationQueueable(
                    selectedApplicationIds
                )
            );
        }
    }
}