public with sharing class ApplicationNotificationQueueable
    implements Queueable {

    private Set<Id> applicationIds;

    public ApplicationNotificationQueueable(Set<Id> applicationIds) {
        this.applicationIds = applicationIds;
    }

    public void execute(QueueableContext context) {

        List<Job_Application__c> applications = [

            SELECT Id,
                   Candidate__c,
                   Candidate__r.Name,
                   Application_Status__c
            FROM Job_Application__c
            WHERE Id IN :applicationIds

        ];

        for (Job_Application__c app : applications) {

            System.debug(
                'Offer Notification Sent To: '
                + app.Candidate__r.Name
            );

        }

    }

}