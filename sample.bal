import ballerina/http;
import ballerina/mime;

//callback record

type CallbackCamunda record {
    string processDefinitionId;
    string status;

};

type CallBackConfig record {
    string CALLBACK_END_POINT;

};
type WorkflowRequestTypeVarible record {
    string name;
    string value;
};

type WorkflowRequestType record {
    string processDefinitionId;
    string workflowID;
    WorkflowRequestTypeVarible[] variables;
};
type WorkflowEngineType record {
   string TYPE;
};
configurable CallBackConfig callbackconfig = ?;


service / on new http:Listener(8090) {

    resource function post .(http:Caller caller, http:Request request) returns error? {

        json requestWorkflowPayload = check request.getJsonPayload();
         WorkflowRequestType workflowRequestType = check requestWorkflowPayload.cloneWithType(WorkflowRequestType);
     
            WorkflowEngine workflowEngine = check createWorkflowEngine(workflow_engine_config.TYPE);

            any workflowInitializer = check workflowEngine.workflowInitializer(workflowRequestType);
            check caller->respond(workflowInitializer.toString());
       
       

    }

    resource function post CallbackEndPoint(http:Caller caller, http:Request request) returns error? {
        http:Client CallbackIS = check new (callbackconfig.CALLBACK_END_POINT);

        json callbackPayload = check request.getJsonPayload();
        CallbackCamunda inputRecord = check callbackPayload.cloneWithType(CallbackCamunda);
        string processuuid = inputRecord.processDefinitionId;
        json payload = {
            "status": inputRecord.status
        };

        map<string> headers = {"Content-Type": mime:APPLICATION_JSON};
        http:Response res = check CallbackIS->patch(processuuid, payload, headers);

        check caller->respond(res.statusCode);

    }

}

