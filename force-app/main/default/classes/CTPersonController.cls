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
        Map<String, Integer> mapOfHealthSatusCount = new Map<String,Integer>();
        
        AggregateResult[] groupResult = [SELECT Health_Status__c, COUNT(Id) total // must give alias to use aggregated fields
        FROM Person__c
        GROUP BY Health_Status__c];

        for(AggregateResult result : groupResult){
            mapOfHealthSatusCount.put((String)result.get('Health_Status__c'), (Integer)result.get('total')); // typecas from type object to correct data type, as get method returns type object
        }
        return mapOfHealthSatusCount;
    }

}