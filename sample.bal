import ballerina/http;
import ballerina/mime;

//callback record

type CallbackCamunda record {
    string requestID;
    string status;

};

type CallBackConfig record {
    string CALLBACK_END_POINT;

};
public type WorkflowRequestVarible record {
    string name;
    string value;
};

# Description
#
# + requestId - Request Idenitifier and this use for callback function  
# + workflowID - External workflow Identifier   
# + variables - List of varibles which recived from the request
public type WorkflowRequest record {
    string requestId;
    string workflowID;
    WorkflowRequestVarible[] variables;
};
type WorkflowEngineType record {
   string TYPE;
};
configurable CallBackConfig callbackconfig = ?;


service / on new http:Listener(8090) {

    resource function post .(http:Caller caller, http:Request request) returns error? {

        json requestWorkflowPayload = check request.getJsonPayload();
         WorkflowRequest workflowRequestType = check requestWorkflowPayload.cloneWithType(WorkflowRequest);
     
            WorkflowEngine workflowEngine = check createWorkflowEngine(workflow_engine_config.TYPE);

            any workflowInitializer = check workflowEngine.workflowInitializer(workflowRequestType);
            check caller->respond(workflowInitializer.toString());
       
       

    }

    resource function post Callback(http:Caller caller, http:Request request) returns error? {
        http:Client CallbackIS = check new (callbackconfig.CALLBACK_END_POINT);

        json callbackPayload = check request.getJsonPayload();
        CallbackCamunda inputRecord = check callbackPayload.cloneWithType(CallbackCamunda);
        string requestID = inputRecord.requestID;
        json payload = {
            "status": inputRecord.status
        };

        map<string> headers = {"Content-Type": mime:APPLICATION_JSON};
        http:Response res = check CallbackIS->patch(requestID, payload, headers);

        check caller->respond(res.statusCode);

    }

}

