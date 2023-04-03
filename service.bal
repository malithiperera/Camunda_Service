import ballerina/http;
type WorkflowRequestType record {
    string processDefinitionId;
    string workflowID;
    WorkflowRequestTypeVarible[] variables;
};
type WorkflowRequestTypeVarible record {
    string name;
    string value;
};
# A service representing a network-accessible API
# bound to port `9090`.
service / on new http:Listener(9090) {

    # A resource for generating greetings
    # + name - the input string name
    # + return - string name with hello message or error
    resource function get greeting(string name) returns string|error {
        // Send a response back to the caller.
        if name is "" {
            return error("name should not be empty!");
        }
        return "Hello, " + name;
    }

    resource function post .(http:Caller caller, http:Request request, string bpsProfile) returns error? {

        json requestWorkflowPayload = check request.getJsonPayload();
         WorkflowRequestType workflowRequestType = check requestWorkflowPayload.cloneWithType(WorkflowRequestType);
        // Extract the "name" parameter from the URL
   
            CamundaService camundaProfile = new CamundaService();

            any workflowInitializer = check camundaProfile.workflowInitializer(workflowRequestType);
            check caller->respond(workflowInitializer.toString());
        
        

    }
}
