public with sharing class CTLocationTracingController {
   public static List<Location_Tracing__c> getVisitors(String locationId){
       // query records that match locationId
       // sort by visit date desc
       // return list
       return [SELECT Id, Person__c, Person__r.Token__c, Person__r.Health_Status__c, Location__c, Visit_Date__c 
                FROM Location_Tracing__c
                WHERE Id = :locationId
                ORDER BY Visit_Date__c DESC NULLS LAST];

   }

    public static List<Location_Tracing__c> getLocationsByPersonIds(Set<Id> personIds){
        // query records where person matches personIds
        // only get records when visit date is in last 10 days
        // return list
        return [SELECT Id, Person__c, Person__r.Token__c, Person__r.Health_Status__c, Location__c, Visit_Date__c 
                FROM Location_Tracing__c
                WHERE Person__c IN :personIds
                AND Visit_Date__c = LAST_N_DAYS:10];
       
    }

    public static List<Location_Tracing__c> getLocationsByLocationIds(Set<Id> locationIds){
        // query records where location matches locationIds
        // only get records when visit date is in last 10 days
        // return list
        return [SELECT Id, Person__c, Person__r.Token__c, Person__r.Health_Status__c, Location__c, Visit_Date__c 
                FROM Location_Tracing__c
                WHERE Location__c IN :locationIds
                AND Person__r.Health_Status__c = 'Green'
                AND Visit_Date__c = LAST_N_DAYS:10];
    }

    public static List<Location_Tracing__c> checkDuplicates(List<Location_Tracing__c> newLoctionTraces){
        // duplicate records = a locationTrace with same LocationId and PersonId
        // loop thru newLoctionTraces to get unique ids and person ids
        // query existing location tracing records usings ids collected above
        
        Set<Id> uniqueLocationIds = new Set<Id>();
        Set<Id> uniquePersonIds = new Set<Id>();
        for(Location_Tracing__c locTrace : newLoctionTraces){
            uniqueLocationIds.add(locTrace.Location__c);
            uniquePersonIds.add(locTrace.Person__c);
        }

        // list contains records with either LocationId or PersonId or Both
        List<Location_Tracing__c> existingRecords = [SELECT Id, Location__c, Person__c
                                                    FROM Location_Tracing__c
                                                    WHERE Location__c IN :uniqueLocationIds
                                                    AND Person__c IN :uniquePersonIds];
        
        // use map to get records with BOTH locationId and personId      
        // 1. check existingRecords list not empty and loop thru list
        // 2. get locationId and put in Map key if map doesnt contain key already
        // 3. create new empty Set as value
        // 4. use key from map to find locationTracing records and put all its PersonIds in Map set                          
        Map<Id,Set<Id>> mapOfExistingRecs = new Map<ID,Set<Id>>();
        if (existingRecords != null && existingRecords.size() > 0) {
            for(Location_Tracing__c trace : existingRecords){
                if (!mapOfExistingRecs.containsKey(trace.Location__c)) {
                    mapOfExistingRecs.put(trace.Location__c, new Set<Id>());
                }
                // add all personIds to map set by the given locationId from the map
                mapOfExistingRecs.get(trace.Location__c).add(trace.Person__c);   
            }  

            List<Location_Tracing__c> duplicates = new List<Location_Tracing__c>();
            // loop over newLoctionTraces and check if locationId and personId are found in Map
            // if record contains BOTH locationId and PersonId then its a duplicate
            for (Location_Tracing__c trace : newLoctionTraces) {
                if (mapOfExistingRecs.containsKey(trace.Location__c) && mapOfExistingRecs.get(trace.Location__c).contains(trace.Person__c)) {
                    duplicates.add(trace);  
                } 
            }
        }
        return duplicates;
    }
}
