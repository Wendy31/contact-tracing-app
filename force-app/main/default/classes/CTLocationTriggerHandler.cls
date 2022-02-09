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
}
