trigger InterviewTrigger on Interview__c (after insert, after update) {

    if (Trigger.isAfter) {

        if (Trigger.isInsert) {
            InterviewTriggerHandler.handleAfterInsert(Trigger.new);
        }

        if (Trigger.isUpdate) {
            InterviewTriggerHandler.handleAfterUpdate(Trigger.new, Trigger.oldMap);
        }
    }
}