trigger CTLocationTrigger on Location__c (before insert, after insert, before update, after update) {
    switch on Trigger.OperationType {
        when BEFORE_INSERT {
            CTLocationTriggerHandler.beforeInsert(Trigger.new);
        }
        when BEFORE_UPDATE {
            CTLocationTriggerHandler.beforeUpdate(Trigger.new, Trigger.oldMap);
        }
        
    }

}