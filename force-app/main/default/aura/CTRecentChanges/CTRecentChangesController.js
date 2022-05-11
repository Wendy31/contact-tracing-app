({
    doInit : function(component, event, helper) {
        const scope = component.get("v.scope");
        if (scope === "person") {
        component.set('v.columns', [
            {label: 'Name', fieldName: 'Name', type: 'text'},
            {label: 'Mobile', fieldName: 'Mobile__c', type: 'text'},
            {label: 'Token', fieldName: 'Token__c', type: 'text'},
            {label: 'Health Status', fieldName: 'Health_Status__c', type: 'text'},
            {label: 'Status Update Date', fieldName: 'Status_Update_Date__c ', type: 'date'}
        ]);
    }else {
        component.set('v.columns', [
            {label: 'Name', fieldName: 'Name', type: 'text'},
            {label: 'Status', fieldName: 'Status__c', type: 'text'},
            {label: 'Red Score', fieldName: 'Red_Score__c', type: 'number'},
            {label: 'Pincode', fieldName: 'Pincode__c', type: 'text'},
            {label: 'Address', fieldName: 'Address__c', type: 'text'},
            {label: 'Status Update Date', fieldName: 'Status_Update_Date__c ', type: 'date'}
        ]);
    }
        // call helper method that sets data to datatable right after table is constructed above
        helper.fetchRecentHealthChanges(component);
        // COMMENT ADDED blah blah blah blah blah
    }
});
