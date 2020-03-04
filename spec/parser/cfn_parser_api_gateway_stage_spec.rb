require 'spec_helper'
require 'cfn-model/parser/cfn_parser'

describe CfnParser do
  before :each do
    @cfn_parser = CfnParser.new
  end

  context 'API Gateway Stage with no Usage Plan. ' do
    it 'returns an api stage with no usage plan' do
      expected_api_stage = api_stage_with_no_usage_plans(cfn_model: CfnModel.new)
      test_templates('api_gateway/api_gateway_stage_with_no_usage_plans').each do |test_template|
        cfn_model = @cfn_parser.parse IO.read(test_template)
        api_stages = cfn_model.resources_by_type 'AWS::ApiGateway::Stage'

        expect(api_stages.size).to eq 1
        expect(api_stages[0]).to eq expected_api_stage
        expect(api_stages[0].usage_plans).to eq expected_api_stage.usage_plans
        expect(api_stages[0].usage_plans).to be_empty
      end
    end
  end
  context 'One API Gateway Stage with one Usage Plan. ' do
    it 'returns API Gateway Stage with one Usage Plan' do
      expected_api_stage = api_stage_with_one_usage_plan(cfn_model: CfnModel.new)
      test_templates('api_gateway/api_gateway_stage_with_one_usage_plan').each do |test_template|
        cfn_model = @cfn_parser.parse IO.read(test_template)
        api_stages = cfn_model.resources_by_type 'AWS::ApiGateway::Stage'

        expect(api_stages.size).to eq 1
        expect(api_stages[0]).to eq expected_api_stage
        expect(api_stages[0].usage_plans).not_to be_empty
        expect(api_stages[0].usage_plans).to eq expected_api_stage.usage_plans
      end
    end
  end

  context 'One API Gateway Stage with two Usage Plans. ' do
    it 'One API Gateway Stage with two Usage Plans.' do
      expected_api_stage = one_api_stage_with_two_usage_plans(cfn_model: CfnModel.new)
      test_templates('api_gateway/one_api_gateway_stage_with_two_usage_plans').each do |test_template|
        cfn_model = @cfn_parser.parse IO.read(test_template)
        api_stages = cfn_model.resources_by_type 'AWS::ApiGateway::Stage'

        expect(api_stages.size).to eq 1
        expect(api_stages[0]).to eq expected_api_stage
        expect(api_stages[0].usage_plans).not_to be_empty
        expect(api_stages[0].usage_plans).to eq expected_api_stage.usage_plans
      end
    end
  end

  context 'Two API Gateway Stages associated with one Usage Plan. ' do
    it 'Two API Gateway Stages associated with one Usage Plan' do
      expected_api_stage_1, expected_api_stage_2 = twp_api_stages_with_one_usage_plan(cfn_model: CfnModel.new)

      test_templates('api_gateway/two_api_gateway_stages_with_one_usage_plan').each do |test_template|
        cfn_model = @cfn_parser.parse IO.read(test_template)
        api_stages = cfn_model.resources_by_type 'AWS::ApiGateway::Stage'

        expect(api_stages.size).to eq 2
        expect(api_stages[0]).to eq expected_api_stage_1
        expect(api_stages[1]).to eq expected_api_stage_2
        expect(api_stages[0].usage_plans).to eq expected_api_stage_1.usage_plans
        expect(api_stages[1].usage_plans).to eq expected_api_stage_2.usage_plans
      end
    end
  end

  context 'Two API Gateway Stages - each associated with a different Usage Plan. ' do
    it 'Two API Gateway Stages - each associated with a different Usage Plan' do
      expected_api_stage_1, expected_api_stage_2 = twp_api_stages_each_with_different_usage_plans(cfn_model: CfnModel.new)

      test_templates('api_gateway/two_api_gateway_stages_each_with_different_usage_plan').each do |test_template|
        cfn_model = @cfn_parser.parse IO.read(test_template)
        api_stages = cfn_model.resources_by_type 'AWS::ApiGateway::Stage'

        expect(api_stages.size).to eq 2
        expect(api_stages[0]).to eq expected_api_stage_1
        expect(api_stages[1]).to eq expected_api_stage_2
        expect(api_stages[0].usage_plans).to eq expected_api_stage_1.usage_plans
        expect(api_stages[1].usage_plans).to eq expected_api_stage_2.usage_plans
      end
    end
  end
######################################################################################
# API STAGE DEPLOYMENT ID TESTING #
######################################################################################
  context 'Two API Gateway Stages - each associated with its own API Deployment. ' do
    it 'Two API Gateway Stages - each associated with its own API Deployment.' do
      expected_api_stage_1, expected_api_stage_2 = twp_api_stages_each_with_different_deployment_id(cfn_model: CfnModel.new)

      test_templates('api_gateway/two_api_gateway_stages_each_with_different_deployment_id').each do |test_template|
        cfn_model = @cfn_parser.parse IO.read(test_template)
        api_stages = cfn_model.resources_by_type 'AWS::ApiGateway::Stage'

        expect(api_stages.size).to eq 2
        expect(api_stages[0]).to eq expected_api_stage_1
        expect(api_stages[1]).to eq expected_api_stage_2
        expect(api_stages[0].deployment_id).to eq expected_api_stage_1.deployment_id
        expect(api_stages[1].deployment_id).to eq expected_api_stage_2.deployment_id
      end
    end
  end

  context 'Two API Gateway Stages - each with no API Deployment. ' do
    it 'Two API Gateway Stages - each with no API Deployment.' do
      expected_api_stage_1, expected_api_stage_2 = twp_api_stages_each_with_no_deployment_id(cfn_model: CfnModel.new)

      test_templates('api_gateway/two_api_gateway_stages_each_with_no_deployment_id').each do |test_template|
        cfn_model = @cfn_parser.parse IO.read(test_template)
        api_stages = cfn_model.resources_by_type 'AWS::ApiGateway::Stage'

        expect(api_stages.size).to eq 2
        expect([api_stages[0], api_stages[1]]).to eq [expected_api_stage_1,
                                                      expected_api_stage_2]
        expect([api_stages[0].deployment_id, api_stages[1].deployment_id]).to eq [expected_api_stage_1.deployment_id,
                                                                                  expected_api_stage_2.deployment_id]
      end
    end
  end

  context 'One API Gateway Stage with a non-referenced hard coded value for DeploymentId. ' do
    it 'One API Gateway Stage with a non-referenced hard coded value for DeploymentId.' do
      expected_api_stage_1 = one_api_gateway_stage_with_hardcoded_deployment_id(cfn_model: CfnModel.new)

      test_templates('api_gateway/one_api_gateway_stage_with_hardcoded_deployment_id').each do |test_template|
        cfn_model = @cfn_parser.parse IO.read(test_template)
        api_stages = cfn_model.resources_by_type 'AWS::ApiGateway::Stage'

        expect(api_stages.size).to eq 1
        expect(api_stages[0]).to eq expected_api_stage_1
        expect(api_stages[0].deployment_id).to eq expected_api_stage_1.deployment_id
        expect(api_stages[0].deployment_id).to be_empty
      end
    end
  end
end