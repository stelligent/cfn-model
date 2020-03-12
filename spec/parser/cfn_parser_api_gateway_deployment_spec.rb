require 'spec_helper'
require 'cfn-model/parser/cfn_parser'

describe CfnParser do
  before :each do
    @cfn_parser = CfnParser.new
  end

  context 'API Gateway Deployment that creates a stage with one Usage Plan. ' do
    it 'returns API Gateway Deployment with one usage plan' do
      expected_api_deployments = api_deployment_with_one_usage_plan(cfn_model: CfnModel.new)
      test_templates('api_gateway/api_gateway_deployment_with_one_usage_plan').each do |test_template|
        cfn_model = @cfn_parser.parse IO.read(test_template)
        api_deployments = cfn_model.resources_by_type 'AWS::ApiGateway::Deployment'

        expect(api_deployments.size).to eq 1
        expect(api_deployments[0]).to eq expected_api_deployments
        expect(api_deployments[0].usage_plan_ids).to eq expected_api_deployments.usage_plan_ids
        expect(api_deployments[0].usage_plan_ids).not_to be_empty
      end
    end
  end
  context 'API Gateway Deployment that creates a stage with no Usage Plan. ' do
    it 'returns API Gateway Deployment with no usage plan' do
      expected_api_deployments = api_deployment_with_no_usage_plan(cfn_model: CfnModel.new)
      test_templates('api_gateway/api_gateway_deployment_with_no_usage_plan').each do |test_template|
        cfn_model = @cfn_parser.parse IO.read(test_template)
        api_deployments = cfn_model.resources_by_type 'AWS::ApiGateway::Deployment'

        expect(api_deployments.size).to eq 1
        expect(api_deployments[0]).to eq expected_api_deployments
        expect(api_deployments[0].usage_plan_ids).to eq expected_api_deployments.usage_plan_ids
        expect(api_deployments[0].usage_plan_ids).to be_empty
      end
    end
  end

  context 'API Gateway Deployment that has no StageName property. ' do
    it 'returns API Gateway Deployment with no stage name' do
      expected_api_deployments = api_deployment_without_stage_name(cfn_model: CfnModel.new)
      test_templates('api_gateway/api_gateway_deployment_without_stage_name').each do |test_template|
        cfn_model = @cfn_parser.parse IO.read(test_template)
        api_deployments = cfn_model.resources_by_type 'AWS::ApiGateway::Deployment'

        expect(api_deployments.size).to eq 1
        expect(api_deployments[0]).to eq expected_api_deployments
        expect(api_deployments[0].usage_plan_ids).to eq expected_api_deployments.usage_plan_ids
        expect(api_deployments[0].usage_plan_ids).to be_empty
      end
    end
  end
end