trigger CTLocationTracingTrigger on Location_Tracing__c (before insert) {
    switch on Trigger.OperationType {
        when BEFORE_INSERT {
            CTLocationTracingTriggerHandler.beforeInsert(Trigger.new);
        }
        when else {
            
        }
    }
}