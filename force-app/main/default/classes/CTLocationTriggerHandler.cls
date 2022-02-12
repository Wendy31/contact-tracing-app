public with sharing class CTLocationTriggerHandler {
    // before inserting location, status must be green
    public static void beforeInsert(List<Location__c> newLocations) {
        for (Location__c location : newLocations) {
            location.Status__c = 'Green'; 
        }
    }
    // if location status changes, update Status update Date
    public static void beforeUpdate(List<Location__c> newLocations, Map<Id,Location__c> oldLocationsMap) {
        for (Location__c location : newLocations) {
            if (location.Status__c != oldLocationsMap.get(location.Id).Status__c) {
                location.Status_Update_Date__c = Date.today();
            }
        }
    }

    public static void afterUpdate(List<Location__c> newLocations, Map<Id,Location__c> oldLocationsMap ){
        // if location status changed to red
        // query people from locationTracing of that red location
        // get the IDs and set those people status to yellow
        Set<Id> redLocations = new Set<Id>();
        for (Location__c location : newLocations) {
            if(oldLocationsMap.get(location.Id).Status__c != 'Red' && location.Status__c == 'Red'){
                redLocations.add(location.Id);
            }
        }

        List<Location_Tracing__c> locationTraces = CTLocationTracingController.getLocationsByLocationIds(redLocations);
        Set<Id> peopleID = new Set<Id>();
        for (Location_Tracing__c trace : locationTraces) {
            peopleID.add(trace.Person__c);  
        }

        List<Person__c> peopleToUpdate = new List<Person__c>();
        for (Id pId : peopleID) {
            peopleToUpdate.add(new Person__c(Id = pId, Health_Status__c = 'Yellow'));
        }

        if (peopleToUpdate.size() > 0) {
            update peopleToUpdate;
        }
    }
}
