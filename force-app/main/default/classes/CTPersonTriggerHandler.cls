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

        Set<Id> orangeStatus = new Set<Id> (); 
        Set<Id> yellowStatus = new Set<Id> (); 
    }
    

   
}