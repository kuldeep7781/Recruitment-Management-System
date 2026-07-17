public with sharing class StaleApplicationBatch
    implements Database.Batchable<SObject>, Database.Stateful {

    private Integer processedRecords = 0;

    public Database.QueryLocator start(Database.BatchableContext bc) {

        return Database.getQueryLocator([
            SELECT Id,
                   Applied_Date__c,
                   Application_Status__c
            FROM Job_Application__c
            WHERE Applied_Date__c <= :Date.today().addDays(-30)
            AND Application_Status__c IN (
                :RecruitmentConstants.STATUS_APPLIED,
                :RecruitmentConstants.STATUS_SCREENING
            )
        ]);
    }

    public void execute(
        Database.BatchableContext bc,
        List<Job_Application__c> scope
    ) {

        for (Job_Application__c application : scope) {

            application.Application_Status__c =
                RecruitmentConstants.STATUS_WITHDRAWN;

            processedRecords++;
        }

        if (!scope.isEmpty()) {
            update scope;
        }
    }

    public void finish(Database.BatchableContext bc) {

        System.debug(
            'StaleApplicationBatch completed successfully.'
        );

        System.debug(
            'Applications Updated : ' + processedRecords
        );
    }
}