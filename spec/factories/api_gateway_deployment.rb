require 'cfn-model/model/api_gateway_stage'
require 'cfn-model/model/cfn_model'

def api_deployment_with_one_usage_plan(cfn_model: CfnModel.new)
  api_deployment = AWS::ApiGateway::Deployment.new cfn_model
  api_deployment.restApiId = 'testapi1'
  api_deployment.stageName = 'test-stage-1'
  api_deployment.stageDescription = {"AccessLogSetting" =>
                                         {"DestinationArn" => 'arn:aws:iam::123456789012:log-group/api-gateway-stage',
                                          "Format" => '$context.requestId'}}
  api_deployment.usage_plan_ids << 'ApiGatewayUsagePlan1'
  api_deployment
end

def api_deployment_with_no_usage_plan(cfn_model: CfnModel.new)
  api_deployment = AWS::ApiGateway::Deployment.new cfn_model
  api_deployment.restApiId = 'testapi1'
  api_deployment.stageName = 'test-stage-1'
  api_deployment.stageDescription = {"AccessLogSetting" =>
                                         {"DestinationArn" => 'arn:aws:iam::123456789012:log-group/api-gateway-stage',
                                          "Format" => '$context.requestId'}}
  api_deployment
end

def api_deployment_without_stage_name(cfn_model: CfnModel.new)
  api_deployment = AWS::ApiGateway::Deployment.new cfn_model
  api_deployment.restApiId = 'testapi1'
  api_deployment.stageDescription = {"AccessLogSetting" =>
                                         {"DestinationArn" => 'arn:aws:iam::123456789012:log-group/api-gateway-stage',
                                          "Format" => '$context.requestId'}}
  api_deployment
end

def api_deployment_refd_in_stage_with_one_usage_plan(cfn_model: CfnModel.new)
  api_deployment = AWS::ApiGateway::Deployment.new cfn_model
  api_deployment.restApiId = 'testapi1'
  ['ApiGatewayUsagePlan1','ApiGatewayUsagePlan2'].each do |apigw_up|
    api_deployment.usage_plan_ids << apigw_up
  end

  api_deployment
end
