type WorkflowEngine distinct service object {
   
    # Description
    #
    # + workflowRequestType - Workflow Request type recived from identity server
    # + return - Any type of value or error
    public function workflowInitializer(WorkflowRequest workflowRequestType) returns any | error;
    
};
