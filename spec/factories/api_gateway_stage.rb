require 'cfn-model/model/api_gateway_stage'
require 'cfn-model/model/cfn_model'

def api_stage_with_no_usage_plan(cfn_model: CfnModel.new)
  api_stage = AWS::ApiGateway::Stage.new cfn_model
  api_stage.restApiId = 'testapi'
  api_stage
end

def api_stage_with_one_usage_plan(cfn_model: CfnModel.new)
  api_stage = AWS::ApiGateway::Stage.new cfn_model

  api_stage.usage_plans << 'ApiGatewayUsagePlan1'
  api_stage.restApiId = 'testapi'
  api_stage
end

def twp_api_stages_with_one_usage_plan(cfn_model: CfnModel.new)
  api_stage_1 = AWS::ApiGateway::Stage.new cfn_model
  api_stage_2 = AWS::ApiGateway::Stage.new cfn_model

  count = 1
  [api_stage_1, api_stage_2].each do |stage|
    stage.restApiId = "testapi_#{count}"
    stage.usage_plans << 'ApiGatewayUsagePlan1'
    count += 1
  end
  [api_stage_1, api_stage_2]
end

def twp_api_stages_each_with_different_usage_plan(cfn_model: CfnModel.new)
  api_stage_1 = AWS::ApiGateway::Stage.new cfn_model
  api_stage_2 = AWS::ApiGateway::Stage.new cfn_model

  count = 1
  [api_stage_1, api_stage_2].each do |stage|
    stage.restApiId = "testapi_#{count}"
    stage.usage_plans << "ApiGatewayUsagePlan#{count}"
    count += 1
  end
  [api_stage_1, api_stage_2]
end

def twp_api_stages_each_with_different_deployment_id(cfn_model: CfnModel.new)
  api_stage_1 = AWS::ApiGateway::Stage.new cfn_model
  api_stage_2 = AWS::ApiGateway::Stage.new cfn_model

  count = 1
  [api_stage_1, api_stage_2].each do |stage|
    stage.restApiId = "testapi_#{count}"
    stage.deploymentId = {'Ref' => "ApiGatewayDeployment#{count}"}
    stage.deployment_id << "ApiGatewayDeployment#{count}"
    count += 1
  end
  [api_stage_1, api_stage_2]
end


def twp_api_stages_each_with_no_deployment_id(cfn_model: CfnModel.new)
  api_stage_1 = AWS::ApiGateway::Stage.new cfn_model
  api_stage_2 = AWS::ApiGateway::Stage.new cfn_model

  count = 1
  [api_stage_1, api_stage_2].each do |stage|
    stage.restApiId = "testapi_#{count}"
    count += 1
  end
  [api_stage_1, api_stage_2]
end

def one_api_gateway_stage_with_hardcoded_deployment_id(cfn_model: CfnModel.new)
  api_stage_1 = AWS::ApiGateway::Stage.new cfn_model
  api_stage_1.restApiId = 'testapi_1'
  api_stage_1.deploymentId = 'hardcoded_value'

  api_stage_1
end
