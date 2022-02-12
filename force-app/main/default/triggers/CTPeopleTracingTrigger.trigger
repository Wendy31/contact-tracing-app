trigger CTPeopleTracingTrigger on People_Tracing__c (before insert) {
    switch on trigger.operationType {
        when BEFORE_INSERT {
            CTPeopleTracingTriggerHandler.beforeInsert(Trigger.new);
        }
        when BEFORE_UPDATE {
            
        }
    } 
}