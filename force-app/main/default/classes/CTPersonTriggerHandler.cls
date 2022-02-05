public with sharing class CTPersonTriggerHandler {
    public static void beforeInsert(List<Person__c> newPersons) {
        // check health status = green before insertion
        // and generate unique token for the person
        // when health status updates, update the status_update_date field 

        for (Person__c person : newPersons) {
            person.Health_Status__c = 'Green';
            person.Token__c = CTPersonController.getToken(person.Mobile__c); 
            
        }
    }

    public static void beforeUpdate(List<Person__c> newPersons, Map<Id,Person__c> oldPersonsMap){
        for (Person__c person : newPersons) {
            if (person.Health_Status__c !=  oldPersonsMap.get(person.Id).Health_Status__c){
                person.Status_Update_Date__c = Date.today();
            }
            
        }
    }

    public static void afterUpdate(List<Person__c> newPersons, Map<Id,Person__c> oldPersonsMap){
        Set<Id> healthStatusChange = new Set<Id> (); // stores all people with any status change
        Set<Id> redStatus = new Set<Id> (); // stores people with only red status
        for (Person__c person : newPersons) {
            // if the health status changes to anything
            if (person.Health_Status__c !=  oldPersonsMap.get(person.Id).Health_Status__c){
                healthStatusChange.add(person.Id);  
            }

            // if the health status changes to red, update locations visited in the last 10 days
            // if status = red and old record was not red before 
            if (person.Health_Status__c == 'Red' && oldPersonsMap.get(person.Id).Health_Status__c != 'Red'){
                redStatus.add(person.Id);
            }  
        }

        // store people in the correct colour statuses
        // cohabitants/ pimary contacts = Orange
        // neighbours/ secondary contacts = yellow
        // dont process people that have already been processed 
        Set<Id> alreadyProcessed = new Set<Id>();
        Set<Id> orangeStatus = new Set<Id> (); 
        Set<Id> yellowStatus = new Set<Id> (); 
        List<Person__c> peopleToUpdate = new List<Person__c>();

        // call methods and pass in all red contacts 
        orangeStatus.addAll(CTPersonController.getCohabitants(redStatus, alreadyProcessed));
        Set<Id> primaryContacts = CTPersonController.getPrimaryContacs(redStatus, alreadyProcessed);
        orangeStatus.addAll(primaryContacts);
        yellowStatus.addAll(CTPersonController.getNeighbours(redStatus, alreadyProcessed));
        // pass in the primary contacts to secondary method
        yellowStatus.addAll(CTPersonController.getSecondaryContacs(primaryContacts, alreadyProcessed));

        // once all groups are sorted into color lists
        // we need to use IDs in list to update their status
        // store in list and mass update
        for (Id pId : orangeStatus) {
            peopleToUpdate.add(new Person__c(Id = pId, Health_Status__c = 'Orange'));
        }

        for (Id pId : yellowStatus) {
            peopleToUpdate.add(new Person__c(Id = pId, Health_Status__c = 'Yellow'));
        }
        if (peopleToUpdate != null && peopleToUpdate.size() > 0) {
            update peopleToUpdate;
        } 

        // update all persons' location Red Score and Status
        // call method and pass in all people who had a status change
        // from LocationTracing, get all location IDs

        List <Location_Tracing__c> locationTraces = CTLocationTracingController.getLocationsByPersonIds(healthStatusChange);
        if (locationTraces !=null && locationTraces.size() > 0) {
            Set<Id> locationIds = new Set<Id>();
            for (Location_Tracing__c trace : locationTraces) {
                locationIds.add(trace.Location__c);
            }
        }
    }
}