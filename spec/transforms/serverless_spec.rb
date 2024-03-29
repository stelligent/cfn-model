# frozen_string_literal: true

require 'spec_helper'
require 'cfn-model/parser/cfn_parser'
require 'cfn-model/transforms/serverless'

describe CfnModel::Transforms::Serverless do
  before :each do
    @cfn_parser = CfnParser.new
  end

  context 'Template without serverless transform' do
    it 'Does not modify a template without AWS::Serverless::Function' do
      cloudformation_template_yml = \
        yaml_test_template('ec2_instance/instance_with_sgid_list_ref')
      actual_cfn_model = @cfn_parser.parse cloudformation_template_yml
      expect(actual_cfn_model.raw_model).to(
        eq(
          YAML.safe_load(
            yaml_test_template(
              'ec2_instance/instance_with_sgid_list_ref'
            )
          )
        )
      )
    end
    it 'Does not modify a template with AWS::Serverless::Function' do
      cloudformation_template_yml = \
        yaml_test_template('sam/sam_without_serverless')
      actual_cfn_model = @cfn_parser.parse cloudformation_template_yml
      expect(actual_cfn_model.raw_model).to(
        eq(
          YAML.safe_load(
            yaml_test_template(
              'sam/sam_without_serverless'
            )
          )
        )
      )
    end
  end

  context 'Template with serverless transform' do
    it 'Removes AWS::Serverless::Function resource' do
      cloudformation_template_yml = \
        yaml_test_template('sam/valid_simple_lambda_fn')
      actual_cfn_model = @cfn_parser.parse cloudformation_template_yml
      expect(
        actual_cfn_model.raw_model['Resources']['MyServerlessFunctionLogicalID']['Type']
      ).not_to(
        eq 'AWS::Serverless::Function'
      )
    end
    it 'Adds AWS::Lambda::Function resource' do
      cloudformation_template_yml = \
        yaml_test_template('sam/valid_simple_lambda_fn')
      actual_cfn_model = @cfn_parser.parse cloudformation_template_yml
      expect(
        actual_cfn_model.raw_model['Resources']['MyServerlessFunctionLogicalID']['Type']
      ).to(
        eq 'AWS::Lambda::Function'
      )
      expect(
        actual_cfn_model.raw_model['Resources']['MyServerlessFunctionLogicalID']['Properties']
      ).not_to include('ReservedConcurrentExecutions')
      expect(
        actual_cfn_model.raw_model['Resources']['MyServerlessFunctionLogicalID'].key?('Metadata')
      ).to be false
    end
    it 'Ensures "FunctionNameRole" AWS::IAM::Role' do
      cloudformation_template_yml = \
        yaml_test_template('sam/valid_simple_lambda_fn')
      actual_cfn_model = @cfn_parser.parse cloudformation_template_yml
      expect(
        actual_cfn_model.raw_model['Resources']['MyServerlessFunctionLogicalIDRole']['Type']
      ).to(
        eq 'AWS::IAM::Role'
      )
    end

    context 'Template with serverless transform and Globals' do
      it 'Validates globals are used to override function params' do
        cloudformation_template_yml = yaml_test_template('sam/globals')
        actual_cfn_model = @cfn_parser.parse cloudformation_template_yml

        expected_bucket = 'bucket.lambda.${Site}'

        expected_endpoint_configuration = 'REGIONAL'
        expected_key = 'lambda/code/${Site}/jar-with-dependencies.jar'
        expected_runtime = 'java8'

        actual_bucket = actual_cfn_model.resources['SomeFunction'].code['S3Bucket']
        actual_key = actual_cfn_model.resources['SomeFunction'].code['S3Key']
        actual_runtime = actual_cfn_model.resources['SomeFunction'].runtime
        global_endpoint_configuration = actual_cfn_model.globals['Api'].endpointConfiguration
        global_runtime = actual_cfn_model.globals['Function'].runtime

        expect(
          actual_cfn_model.raw_model['Resources']['SomeFunction']['Properties']
        ).to include('ReservedConcurrentExecutions')

        expect(actual_bucket).to eq expected_bucket
        expect(actual_key).to eq expected_key
        expect(actual_runtime).to eq expected_runtime
        expect(global_endpoint_configuration).to eq expected_endpoint_configuration
        expect(global_runtime).to eq expected_runtime
      end
    end
  end

  context 'Template with serverless transform and metadata' do
    it 'Adds metadata to transformed resources' do
      cloudformation_template_yml = \
        yaml_test_template('sam/valid_metadata_lambda_fn')
      actual_cfn_model = @cfn_parser.parse cloudformation_template_yml
      expect(
        actual_cfn_model.raw_model['Resources']['MyServerlessFunctionLogicalID'].key?('Metadata')
      ).to be true
      expect(
        actual_cfn_model.raw_model['Resources']['MyServerlessFunctionLogicalIDRole'].key?('Metadata')
      ).to be true
    end
    it 'Adds metadata to transformed resources without role' do
      cloudformation_template_yml = \
        yaml_test_template('sam/valid_metadata_lambda_fn')
      actual_cfn_model = @cfn_parser.parse cloudformation_template_yml
      expect(
        actual_cfn_model.raw_model['Resources']['MyServerlessFunctionLogicalID'].key?('Metadata')
      ).to be true
      expect(
        actual_cfn_model.raw_model['Resources']['MyServerlessFunctionLogicalIDRole'].key?('Metadata')
      ).to be true
      expect(
        actual_cfn_model.raw_model['Resources']['MyServerlessFunctionLogicalID2'].key?('Metadata')
      ).to be true
    end
  end

  context 'Template with serverless transform without URI' do
    it 'Transforms without error' do
      cloudformation_template_yml = \
        yaml_test_template('sam/sam_without_uri')
      actual_cfn_model = @cfn_parser.parse cloudformation_template_yml
      expect(
        actual_cfn_model.raw_model['Resources']['MyServerlessFunctionLogicalID']['Type']
      ).not_to(
        eq 'AWS::Serverless::Function'
      )
    end
  end

  context 'Template with serverless transform without codeuri and without inline (mangled even!)' do
    it 'Transforms without error' do
      cloudformation_template_yml = \
        yaml_test_template('sam/function_without_codeuri_or_inline')
      actual_cfn_model = @cfn_parser.parse cloudformation_template_yml
      expect(
        actual_cfn_model.raw_model['Resources']['HelloWorldFunction']['Code']
      ).to be_nil
    end
  end

  context 'Template with Serverless function and Api Event' do
    it 'creates ServerlessRestApi-related resources' do
      cloudformation_template_yml = yaml_test_template('sam/serverlessrestapi_as_ref')
      actual_cfn_model = @cfn_parser.parse cloudformation_template_yml
      path_map = actual_cfn_model.resources.values.find do |resource|
        resource.logical_resource_id == 'PathMapping'
      end
      serverlessrestapi = actual_cfn_model.resources.values.find do |resource|
        resource.logical_resource_id == 'ServerlessRestApi'
      end
      serverlessrestapi_deployment = actual_cfn_model.resources.values.find do |resource|
        resource.logical_resource_id == 'ServerlessRestApiDeployment'
      end
      serverlessrestapi_stage = actual_cfn_model.resources.values.find do |resource|
        resource.logical_resource_id == 'ServerlessRestApiProdStage'
      end

      expect(path_map.resource_type).to eq 'AWS::ApiGateway::BasePathMapping'
      expect(serverlessrestapi).to_not be_nil
      expect(serverlessrestapi.body['paths']['/mars']).to_not be_nil
      expect(serverlessrestapi_deployment).to_not be_nil
      expect(serverlessrestapi_stage).to_not be_nil
    end
  end

  context 'Template with Serverless function but no Api Event' do
    it 'does not create ServerlessRestApi-related resources' do
      cloudformation_template_yml = yaml_test_template('sam/no_serverlessrestapi')
      actual_cfn_model = @cfn_parser.parse cloudformation_template_yml
      serverlessrestapi = actual_cfn_model.resources.values.find do |resource|
        resource.logical_resource_id == 'ServerlessRestApi'
      end
      serverlessrestapi_deployment = actual_cfn_model.resources.values.find do |resource|
        resource.logical_resource_id == 'ServerlessRestApiDeployment'
      end
      serverlessrestapi_stage = actual_cfn_model.resources.values.find do |resource|
        resource.logical_resource_id == 'ServerlessRestApiProdStage'
      end

      expect(serverlessrestapi).to be_nil
      expect(serverlessrestapi_deployment).to be_nil
      expect(serverlessrestapi_stage).to be_nil
    end
  end

  context 'Template with Serverless function but no Api Event parsed with line numbers' do
    it 'does not create ServerlessRestApi-related resources' do
      cloudformation_template_yml = yaml_test_template('sam/no_serverlessrestapi')
      actual_cfn_model = @cfn_parser.parse cloudformation_template_yml, nil, true
      serverlessrestapi = actual_cfn_model.resources.values.find do |resource|
        resource.logical_resource_id == 'ServerlessRestApi'
      end
      serverlessrestapi_deployment = actual_cfn_model.resources.values.find do |resource|
        resource.logical_resource_id == 'ServerlessRestApiDeployment'
      end
      serverlessrestapi_stage = actual_cfn_model.resources.values.find do |resource|
        resource.logical_resource_id == 'ServerlessRestApiProdStage'
      end

      expect(serverlessrestapi).to be_nil
      expect(serverlessrestapi_deployment).to be_nil
      expect(serverlessrestapi_stage).to be_nil
    end
  end

  context 'Templates with line numbers enabled' do
    it 'assigns line numbers to function resource' do
      cloudformation_template_yml = yaml_test_template('sam/valid_simple_lambda_fn')
      actual_cfn_model = @cfn_parser.parse cloudformation_template_yml, nil, true

      lambda_function = actual_cfn_model.resources_by_type('AWS::Lambda::Function').first
      expect(actual_cfn_model.line_numbers[lambda_function.logical_resource_id]).to eq(7)
    end

    it 'assigns line numbers to role resource' do
      cloudformation_template_yml = yaml_test_template('sam/valid_simple_lambda_fn')
      actual_cfn_model = @cfn_parser.parse cloudformation_template_yml, nil, true

      iam_role = actual_cfn_model.resources_by_type('AWS::IAM::Role').first
      expect(actual_cfn_model.line_numbers[iam_role.logical_resource_id]).to eq(7)
    end

    it 'assigns line numbers to serverless event resources' do
      cloudformation_template_yml = yaml_test_template('sam/serverlessrestapi_as_ref')
      actual_cfn_model = @cfn_parser.parse cloudformation_template_yml, nil, true

      expect(actual_cfn_model.line_numbers['ServerlessRestApi']).to eq(15)
      expect(actual_cfn_model.line_numbers['ServerlessRestApiDeployment']).to eq(15)
      expect(actual_cfn_model.line_numbers['ServerlessRestApiProdStage']).to eq(15)
    end
  end

  context 'Templates with line numbers disabled' do
    it 'does not assign line numbers to function resource' do
      cloudformation_template_yml = yaml_test_template('sam/valid_simple_lambda_fn')
      actual_cfn_model = @cfn_parser.parse cloudformation_template_yml, nil, false

      expect(actual_cfn_model.line_numbers).to be_empty
    end
  end
end
