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
    end
    it 'Ensures "FunctionNameRole" AWS::IAM::Role' do
      cloudformation_template_yml = \
        yaml_test_template('sam/valid_simple_lambda_fn')
      actual_cfn_model = @cfn_parser.parse cloudformation_template_yml
      expect(
        actual_cfn_model.raw_model['Resources']['FunctionNameRole']['Type']
      ).to(
        eq 'AWS::IAM::Role'
      )
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
end
