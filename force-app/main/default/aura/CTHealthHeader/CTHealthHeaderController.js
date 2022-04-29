({
    createRecord: function (component, event, helper) {
        // use standard lightning event to show modal to create record
        // use scope to determine which record to create
        // then give the object names
        // and fire the create record event
        const createRecordEvent = $A.get("e.force:createRecord"); // call the createRecord event
        const scope = component.get("v.scope");
        createRecordEvent.setParams({
            "entityApiName": scope === "person" ? "Person__c" : "Location__c"
        });
        createRecordEvent.fire();
    },

    doInit: function (component, event, helper){
        helper.fetchStatusCount(component);
    }
});