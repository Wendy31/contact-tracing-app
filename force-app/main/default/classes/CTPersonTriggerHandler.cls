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
    

    public static void afterUpdate(List<Person__c> oldPersons, Map<Id,Person__c> newPersonsMap){
        // 1. if person's health status changes update the Red Score and Status of all locations they visited last 10 days
        Set<Id> personIds = new Set<Id>();
        for (Person__c person : oldPersons) {
            personIds.add(person.Id);
        }

        Location_Tracing__c traces = [SELECT Id, Person__c, Location__c 
                                        FROM Location_Tracing__c
                                        WHERE Person__c IN :personIds];


        
        // 2. if person's health status changes to Red 
        //// set cohabitants status = orange
        //// primary contacts = orange
        //// neighbours = yellow
        //// secondary contacts = yellow
        //// update Red Score and Status of all locations they visited the last 10 days

    }
}