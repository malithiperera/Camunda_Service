
import ballerina/http;

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

type DefinitionID record {
    string identity_server_workflow_id ?;
    string workflow_engine_workflow_id;
};

type CamundaConfig record {|
string TYPE;
    string ENGINE_URL;

|};

configurable CamundaConfig workflow_engine_config = ?;
configurable DefinitionID[] workflow_configs = ?;

distinct service class CamundaWorkflowEngine {

    *WorkflowEngine;

    private string engineURL;

    private DefinitionID[] definitionIDs;

    function init() {
        self.engineURL = workflow_engine_config.ENGINE_URL;

        self.definitionIDs = workflow_configs;
    }

    # Description
    #
    # + workflowRequestType - Parameter Description
    # + return - Return Value Description
    public function workflowInitializer(WorkflowRequestType workflowRequestType) returns any?|error {
        string workflowID = workflowRequestType.workflowID;
        string workflowDefinitionID = "";
        foreach var item in self.definitionIDs {
            if (item["identity_server_workflow_id"] == workflowID) {
                workflowDefinitionID = item["workflow_engine_workflow_id"];
                break;
            }

        }
        http:Client clientCamunda = check new (self.engineURL);
        CamundaOutputType camundaPayload = check self.CamundaConvert(workflowRequestType);
        http:Response res = check clientCamunda->post("/" + workflowDefinitionID + "/start", camundaPayload, {});
        return res.statusCode;

    }
    # Description
    # the requrst json payload converts the data format whih except from camunda engine
    # + workflowRequestType - json data format. 
    # + return - requset type json data format.
    #
    private isolated function CamundaConvert(WorkflowRequestType workflowRequestType) returns error|CamundaOutputType {

        string uuid = workflowRequestType.processDefinitionId;

        CamundaOutputType outputType = {
            variables: {}
        };
        outputType.variables["processDefinitionId"] = {
            value: uuid
        };
        foreach CamundaInputTypeVariable inputVariable in workflowRequestType.variables {
            if (inputVariable.name == "Username") {
                outputType.variables[inputVariable.name] = {
                    value: inputVariable.value
                };
            }

        }
        return outputType;
    }
  
}
