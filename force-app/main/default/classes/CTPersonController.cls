public with sharing class CTPersonController {
    public static String getToken(String mobile){
    // generate unique hash using MD5 hashing
    // use method generateDigest() to create one way hash, same input will always generate same output
        Blob mobileValue = Blob.valueOf(mobile);
        Blob hash = Crypto.generateDigest('MD5', mobileValue);
    // get string value of hash blob
        String token = EncodingUtil.base64Encode(hash);
    // return string token to method caller
        return token;
    }

    public static List<Person__c> getRecentHealthChanges(){
        // query person records, limit result to 100
        // sort by status update date in desc order
        // return list of person records
        return [SELECT Id, Name, Health_Status__c, Mobile__c, Status_Update_Date__c, Token__c
                FROM Person__c
                ORDER BY Status_Update_Date__c DESC NULLS LAST
                LIMIT 100];
        
    }

    public static List<Person__c> searchPeople(String searchTerm){
        // query person records where name, mobile, token matches searchTerm
        // sort by status update date in desc order
        // return list of person records
        searchTerm = searchTerm + '%';
        return [SELECT Id, Name, Health_Status__c, Mobile__c, Status_Update_Date__c, Token__c
                FROM Person__c
                WHERE Name LIKE :searchTerm 
                OR Mobile__c LIKE :searchTerm
                OR Token__c LIKE :searchTerm
                ORDER BY Status_Update_Date__c DESC NULLS LAST];
    }

    public static Person__c getPersonById(String personId){
        // query a person record where ID matches personId
        // return the person record
        List<Person__c> people = [SELECT Id, Name, Health_Status__c, Mobile__c, Status_Update_Date__c, Token__c
                FROM Person__c
                WHERE Id = :personId];
        if (people != null && people.size() > 0) {
            return people[0];
        } else {
            return null;
        }
    }

    public static Map<String,Integer> getHealthStatusCount(){
        // query to find number of people in each health status
        // store result in map, the count of people in each status
        // return map
        AggregateResult[] groupResult = [SELECT Health_Status__c, COUNT(Id) total // must give alias to use aggregated fields
        FROM Person__c
        GROUP BY Health_Status__c];
        if (groupResult != null && groupResult.size() > 0) {
            Map<String, Integer> mapOfHealthSatusCount = new Map<String,Integer>();
            for(AggregateResult result : groupResult){
                mapOfHealthSatusCount.put((String)result.get('Health_Status__c'), (Integer)result.get('total')); // typecas from type object to correct data type, as get method returns type object
            }
            return mapOfHealthSatusCount;
        }
        return null;
    }

    // method to get the cohabitants of the people passed.
    // these people can not be their own cohabitant, so check for any duplicates
    // only get cohabitants that are not already red or orange statuses
    // check for both person 1 and person 2
    public static Set<Id> getCohabitants(Set<Id> personIds, Set<Id> alreadyProcessed) {
        List<String> healthStatuses = new List<String>{'Green', 'Yellow'};
        List<People_Tracing__c> peopleTraces = [SELECT Id, Person_1__c, Person_2__c
                                                FROM People_Tracing__c
                                                WHERE (Person_1__c IN :personIds OR Person_2__c IN :personIds)
                                                AND Contact_Type__c = 'Cohabitant'
                                                AND (Person_1__r.Health_Status__c IN :healthStatuses OR Person_2__r.Health_Status__c IN :healthStatuses)];

        // make sure we dont return the same person as their own cohabitant
        Set<Id> cohabitantsId = new Set<Id>();                        
        for (People_Tracing__c peopleTrace : peopleTraces) {
            // if not in alreadyProcessed set, then process these persons as cohabitants but add them in alreadyProcessed once done to build the set on
            if (!alreadyProcessed.contains(peopleTrace.Person_1__c)) {
                cohabitantsId.add(peopleTrace.Person_1__c);
                alreadyProcessed.add(peopleTrace.Person_1__c);
            }

            if (!alreadyProcessed.contains(peopleTrace.Person_2__c)) {
                cohabitantsId.add(peopleTrace.Person_2__c);
                alreadyProcessed.add(peopleTrace.Person_2__c);
            }  
        } 
        return cohabitantsId;
    }

    // get neightbours of the personIds passed in
    public static Set<Id> getNeighbours(Set<Id> personIds, Set<Id> alreadyProcessed) {
        List<People_Tracing__c> peopleTraces = [SELECT Id, Person_1__c, Person_2__c
                                                FROM People_Tracing__c
                                                WHERE (Person_1__c IN :personIds OR Person_2__c IN :personIds)
                                                AND Contact_Type__c = 'Neighbour'
                                                AND (Person_1__r.Health_Status__c = 'Green' OR Person_2__r.Health_Status__c = 'Green')];

        // make sure we dont return the same person as their own neighbour
        Set<Id> neighboursId = new Set<Id>();                        
        for (People_Tracing__c peopleTrace : peopleTraces) {
            if (!alreadyProcessed.contains(peopleTrace.Person_1__c)) {
                neighboursId.add(peopleTrace.Person_1__c);
                alreadyProcessed.add(peopleTrace.Person_1__c);
            }

            if (!alreadyProcessed.contains(peopleTrace.Person_2__c)) {
                neighboursId.add(peopleTrace.Person_2__c);
                alreadyProcessed.add(peopleTrace.Person_2__c);
            }  
        } 
        return neighboursId;
    }

    // get primary contacts of the personIds passed in
    // primary contact = other
    // must add condition to only get contacts that have been in contact with the last 10 days
    // health status †hat is not red and orange
    public static Set<Id> getPrimaryContacs(Set<Id> personIds, Set<Id> alreadyProcessed) {
        List<String> healthStatuses = new List<String>{'Green', 'Yellow'};
        List<People_Tracing__c> peopleTraces = [SELECT Id, Person_1__c, Person_2__c
                                                FROM People_Tracing__c
                                                WHERE (Person_1__c IN :personIds OR Person_2__c IN :personIds)
                                                AND Contact_Type__c = 'Other'
                                                AND Contact_Date__c = LAST_N_DAYS:10
                                                AND (Person_1__r.Health_Status__c IN :healthStatuses OR Person_2__r.Health_Status__c IN :healthStatuses)];

        Set<Id> primaryContacts = new Set<Id>();                        
        for (People_Tracing__c peopleTrace : peopleTraces) {
            if (!alreadyProcessed.contains(peopleTrace.Person_1__c)) {
                primaryContacts.add(peopleTrace.Person_1__c);
                alreadyProcessed.add(peopleTrace.Person_1__c);
            }

            if (!alreadyProcessed.contains(peopleTrace.Person_2__c)) {
                primaryContacts.add(peopleTrace.Person_2__c);
                alreadyProcessed.add(peopleTrace.Person_2__c);
            }  
        } 
        return primaryContacts;
    }

    // get secondary contacts of the primary contacts passed in
    // secondary contacts = contacts of the primaryIds
    // must add condition to only get contacts that have been in contact with the last 10 days
    // health status †hat is not red, orange and yellow
    public static Set<Id> getSecondaryContacs(Set<Id> primaryContactsIds, Set<Id> alreadyProcessed) {
        List<People_Tracing__c> peopleTraces = [SELECT Id, Person_1__c, Person_2__c
                                                FROM People_Tracing__c
                                                WHERE (Person_1__c IN :primaryContactsIds OR Person_2__c IN :primaryContactsIds)
                                                AND Contact_Type__c = 'Other'
                                                AND Contact_Date__c = LAST_N_DAYS:10
                                                AND (Person_1__r.Health_Status__c = 'Green' OR Person_2__r.Health_Status__c = 'Green')];

        Set<Id> secondaryContacts = new Set<Id>();                        
        for (People_Tracing__c peopleTrace : peopleTraces) {
            if (!alreadyProcessed.contains(peopleTrace.Person_1__c)) {
                secondaryContacts.add(peopleTrace.Person_1__c);
                alreadyProcessed.add(peopleTrace.Person_1__c);
            }

            if (!alreadyProcessed.contains(peopleTrace.Person_2__c)) {
                secondaryContacts.add(peopleTrace.Person_2__c);
                alreadyProcessed.add(peopleTrace.Person_2__c);
            }  
        } 
        return secondaryContacts;
    }
    

}