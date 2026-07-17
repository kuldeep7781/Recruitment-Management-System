public with sharing class StaleApplicationScheduler
    implements Schedulable {

    public void execute(SchedulableContext sc) {

        Database.executeBatch(
            new StaleApplicationBatch(),
            200
        );

    }

}