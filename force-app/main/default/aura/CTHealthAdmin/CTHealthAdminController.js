({
    tabSelectHandler : function(component, event, helper) {
        // gets the tab IDs
        const selectedTabId = event.getParam("id");
        // then set the headerTitles on the cmp
        if(selectedTabId === "person"){
            component.set("v.headerTitle", "Person View");
        } else {
            component.set("v.headerTitle", "Location View");
        }
        // then set scope
        component.set("v.scope", selectedTabId);
    }
})
