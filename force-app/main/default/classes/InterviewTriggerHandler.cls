public class InterviewTriggerHandler {

    public static void handleAfterInsert(List<Interview__c> newInterviews) {
        RecruitmentService.updateApplicationStatus(newInterviews);
    }

    public static void handleAfterUpdate(
        List<Interview__c> newInterviews,
        Map<Id, Interview__c> oldMap
    ) {
        List<Interview__c> changedInterviews = new List<Interview__c>();

        for (Interview__c interview : newInterviews) {
            Boolean resultChanged = interview.Interview_Result__c !=
                                    oldMap.get(interview.Id).Interview_Result__c;
            if (resultChanged) {
                changedInterviews.add(interview);
            }
        }

        if (!changedInterviews.isEmpty()) {
            RecruitmentService.updateApplicationStatus(changedInterviews);
        }
    }
}