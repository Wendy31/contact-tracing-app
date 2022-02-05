public with sharing class CTLocationController {
    public static List<Location__c> getRecentStatusChanges(){
        // query location records all fields, limit 100
        // sort by status update desc
        // return list locations
        return [SELECT Id, Address__c, Pincode__c, Red_Score__c, Status_Update_Date__c, Status__c
                FROM Location__c 
                ORDER BY Status_Update_Date__c DESC NULLS LAST
                LIMIT 100];

    }

    public static List<Location__c> searchLocations(String searchTerm){
        // query all fields where name, pincode, address matches searchTerm
        // sort by status update desc
        // return list
        searchTerm = searchTerm + '%';
        return [SELECT Id, Address__c, Pincode__c, Red_Score__c, Status_Update_Date__c, Status__c
                FROM Location__c
                WHERE Name LIKE :searchTerm
                OR Pincode__c LIKE :searchTerm
                OR Address__c LIKE :searchTerm
                ORDER BY Status_Update_Date__c DESC NULLS LAST];
        
    }

    public static Location__c getLocationById(String locationId){
        // query one location record  where ID matches locationId
        // return record
        List<Location__c> locations = [SELECT Id 
                                        FROM Location__c
                                        WHERE Id = :locationId];
        
        if (locations != null && locations.size() > 0) {
            return locations[0];   
        } else {
            return null; 
        }
        
    }

    public static void updateRedScore(Set<Id> locationIds){
        List<Location__c> locationToUpdate = new List<Location__c>();
        // get all locations where there has been people with status change (in locationIds) and where red people visited and return the count 
        // group by location i.e. Swansea = 10
        List<AggregateResult> redPeoplePerLocation = [SELECT Location__c, COUNT(Id) total
                                                    FROM Location_Tracing__c
                                                    WHERE Person__r.Health_Status__c = 'Red'
                                                    AND Visit_Date__c = LAST_N_DAYS: 10
                                                    AND Location__c IN :locationIds
                                                    GROUP BY Location__c];

        // loop thru agg list to build new location with Id, recScore, Status
        for (AggregateResult ar : redPeoplePerLocation) {
            Integer redScore = (Integer)ar.get('total');
            String locationId = (String)ar.get('Location__c');
            String status = getStatus(redScore);
            locationToUpdate.add(new Location__c(Id = locationId, Red_Score__c = redScore, Status__c = status));
        }
        if (locationToUpdate != null && locationToUpdate.size() > 0) {
            update locationToUpdate;
        }
    }

    public static String getStatus(Integer redScore){
        if (redScore == 0) {
            return 'Green';
        } else if (redScore <= 5) {
            return 'Yellow';
        } else if (redScore <= 10) {
            return 'Orange';
        } else {
            return 'Red';
        } 
    }

    public static Map<String,Integer> getStatusCount(){
        // query to find number of locations in each health status
        // store result in map, the count of locations in each status
        // return map
        Map<String,Integer> mapOfStatusCount = new Map<String,Integer>();

        for (AggregateResult ar : [SELECT Status__c, COUNT(Id) total
                                    FROM Location__c
                                    GROUP BY Status__c]) {

            mapOfStatusCount.put((String)ar.get('Status__c'), (Integer)ar.get('total'));
        }
        return mapOfStatusCount;
    }

}
