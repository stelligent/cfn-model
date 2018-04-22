require 'spec_helper'
require 'cfn-model/parser/cfn_parser'

describe CfnParser::Transforms::Serverless do
  before :each do
    @cfn_parser = CfnParser.new
  end

  context 'Template without serverless transform' do
    it 'Does not modify a template without AWS::Serverless::Function' do
      cloudformation_template_yml = \
        IO.read(
          yaml_test_templates('ec2_instance/instance_with_sgid_list_ref').first
        )
      actual_cfn_model = @cfn_parser.parse cloudformation_template_yml
    end
    it 'Does not modify a template with AWS::Serverless::Function' do
      cloudformation_template_yml = \
        IO.read(
          yaml_test_templates('sam/sam_without_serverless').first
        )
      actual_cfn_model = @cfn_parser.parse cloudformation_template_yml
    end
  end

  context 'Template with serverless transform' do
    it 'Removes AWS::Serverless::Function resource' do
      cloudformation_template_yml = \
        IO.read(
          yaml_test_templates('sam/valid_simple_lambda_fn').first
        )
      actual_cfn_model = @cfn_parser.parse cloudformation_template_yml
    end
    it 'Adds AWS::Lambda::Function resource' do
      cloudformation_template_yml = \
        IO.read(
          yaml_test_templates('sam/valid_simple_lambda_fn').first
        )
      actual_cfn_model = @cfn_parser.parse cloudformation_template_yml
    end
    it 'Ensures "FunctionNameRole" AWS::IAM::Role' do
      cloudformation_template_yml = \
        IO.read(
          yaml_test_templates('sam/valid_simple_lambda_fn').first
        )
      actual_cfn_model = @cfn_parser.parse cloudformation_template_yml
    end
  end
end
