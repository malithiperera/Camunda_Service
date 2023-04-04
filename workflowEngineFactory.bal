public function createWorkflowEngine(string engine) returns WorkflowEngine|error {
    if (engine == "camunda") {
        return new CamundaWorkflowEngine();
    } else {

        return error("Invalid engine");
    }

}
