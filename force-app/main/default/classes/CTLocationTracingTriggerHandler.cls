public with sharing class CTLocationTracingTriggerHandler {
    public static void beforeInsert(List<Location_Tracing__c> newRecords) {
        List<Location_Tracing__c> duplicates = CTLocationTracingController.checkDuplicates(newRecords);
        // no need to check if duplicates list is empty
        // it will only enter the loop is list is not empty
        for (Location_Tracing__c dupe : duplicates) {
            dupe.addError('Can not insert duplicate record');
        }
    }
}
