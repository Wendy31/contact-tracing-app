public with sharing class CTPeopleTracingController {
    // find the traces of this person, in order to know who all the people they have been in contact with
    public static List<People_Tracing__c> getTraces(String recordId){
        List<People_Tracing__c> people = [SELECT Id, Name, Contact_Date__c, Contact_Type__c, Person_1__c, Person_1__r.Health_Status__c, Person_1__r.Token__c, Person_2__c, Person_2__r.Health_Status__c, Person_2__r.Token__c 
                                            FROM People_Tracing__c
                                            WHERE Person_1__c = :recordId
                                            OR Person_2__c = :recordId
                                            ORDER BY Contact_Date__c DESC];
                
        return people;
    }

    public static List<People_Tracing__c> checkDuplicates(List<People_Tracing__c> newPeopleTraces){
        // query People Tracing records that match recordId
        // sort by Contact Date in desc order
        // return list
        Set<Id> personIds = new Set<Id>();
        // extract the person 1 and 2 IDs from peopleTraces
        for (People_Tracing__c trace : newPeopleTraces) {
            personIds.add(trace.Person_1__c);
            personIds.add(trace.Person_2__c); 
        }

        List<People_Tracing__c> duplicates = new List<People_Tracing__c>();

        // loop thru existingRecs to build map to easily find dupes 
        Map<Id,Set<Id>> mapOfExistingRecs = new Map<Id,Set<Id>>(); // map to easily pair ids together without nested loops

        // query existing records to find if any of them contain those personIDs
        List<People_Tracing__c> existingRecs = [SELECT Id, Person_1__c, Person_2__c
                                                FROM People_Tracing__c
                                                WHERE Person_1__c IN :personIds
                                                OR Person_2__c IN :personIds];

        if (existingRecs != null && existingRecs.size() > 0) {
            for (People_Tracing__c trace : existingRecs) {
                if (!mapOfExistingRecs.containsKey(trace.Person_1__c)) {
                    mapOfExistingRecs.put(trace.Person_1__c, new Set<Id>());
                }
                mapOfExistingRecs.get(trace.Person_1__c).add(trace.Person_2__c);

                // build map for person 2
                if (!mapOfExistingRecs.containsKey(trace.Person_2__c)) {
                    mapOfExistingRecs.put(trace.Person_2__c, new Set<Id>());
                }
                mapOfExistingRecs.get(trace.Person_2__c).add(trace.Person_1__c); 
            }

        // loop thru newPeopleTraces and check if new records contain both person1 and person2 ids, if so then its a duplicate
            for (People_Tracing__c trace : newPeopleTraces) {
                if (
                    (mapOfExistingRecs.containsKey(trace.Person_1__c) && mapOfExistingRecs.get(trace.Person_1__c).contains(trace.Person_2__c))
                    ||
                    (mapOfExistingRecs.containsKey(trace.Person_2__c) && mapOfExistingRecs.get(trace.Person_2__c).contains(trace.Person_1__c))
                ) {
                    duplicates.add(trace);
                }
            } 
        }
        return duplicates; 
    }
}
