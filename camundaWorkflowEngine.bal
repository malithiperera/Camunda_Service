
import ballerina/http;
import ballerina/io;

//Camunda Records

type CamundaInputTypeVariable record {
    string name;
    string value;
};

type CamundaOutputTypeVariable record {
    string value;
};

type CamundaOutputType record {
    map<CamundaOutputTypeVariable> variables;
};


type CamundaConfig record {|
string TYPE;
string ENGINE_URL;

|};

configurable CamundaConfig workflow_engine_config = ?;


distinct service class CamundaWorkflowEngine {

    *WorkflowEngine;

    private string engineURL;


    function init() {
        self.engineURL = workflow_engine_config.ENGINE_URL;

    }

    # Description
    #
    # + workflowRequestType - Parameter Description
    # + return - Return Value Description
    public function workflowInitializer(WorkflowRequest workflowRequestType) returns any?|error {
       
        string workflowDefinitionID = workflowRequestType.workflowID;
        http:Client clientCamunda = check new (self.engineURL);
        CamundaOutputType camundaPayload = check self.CamundaConvert(workflowRequestType);
        io:println("Camunda Payload: ", camundaPayload);
        http:Response res = check clientCamunda->post("/" + workflowDefinitionID + "/start", camundaPayload, {});
        return res.statusCode;

    }
    # Description
    # the requrst json payload converts the data format whih except from camunda engine
    # + workflowRequestType - json data format. 
    # + return - requset type json data format.
    #
    private isolated function CamundaConvert(WorkflowRequest workflowRequestType) returns error|CamundaOutputType {

        string uuid = workflowRequestType.requestId;

        CamundaOutputType outputType = {
            variables: {}
        };
        outputType.variables["requestID"] = {
            value: uuid
        };
        foreach CamundaInputTypeVariable inputVariable in workflowRequestType.variables {
          
                outputType.variables[inputVariable.name] = {
                    value: inputVariable.value
             
            };

        }
        return outputType;
    }
  
}
