trigger JobApplicationTrigger on Job_Application__c (before insert, after update) {

    if (Trigger.isBefore) {

        if (Trigger.isInsert) {
            JobApplicationTriggerHandler.handleBeforeInsert(Trigger.new);
        }
    }

    if (Trigger.isAfter) {

        if (Trigger.isUpdate) {
            JobApplicationTriggerHandler.handleAfterUpdate(
                Trigger.new,
                Trigger.oldMap
            );
        }
    }
}