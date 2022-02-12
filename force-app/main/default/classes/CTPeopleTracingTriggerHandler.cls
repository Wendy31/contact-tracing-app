public with sharing class CTPeopleTracingTriggerHandler {
    public static void beforeInsert(List<People_Tracing__c> peopleTraces) {
        List<People_Tracing__c> duplicates = CTPeopleTracingController.checkDuplicates(peopleTraces);
        if (duplicates != null && duplicates.size() > 0) {
            for (People_Tracing__c dupe : duplicates) {
                dupe.addError('Can not insert duplicate record. Person 1: ' + dupe.Person_1__c +' and Person 2: ' + dupe.Person_2__c);
            } 
        }
    }
}
