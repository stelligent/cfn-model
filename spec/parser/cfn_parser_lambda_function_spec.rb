# frozen_string_literal: true

require 'spec_helper'
require 'cfn-model/parser/cfn_parser'

describe CfnParser do
  before :each do
    @cfn_parser = CfnParser.new
  end

  context 'a template with a lambda function' do
    it 'plays nice with computed role id' do
      json_test_templates('lambda_function/lambda_function_with_getatt_role').each do |template|
        cfn_model = @cfn_parser.parse IO.read(template)

        actual_functions = cfn_model.resources_by_type('AWS::Lambda::Function')
        actual_computed_role = actual_functions.find do |function|
          function.role_id == 'LambdaExecutionRole'
        end
        no_computed_role = actual_functions.find do |function|
          function.role_id == 'WrongExecutionRole'
        end

        expect(actual_computed_role).to_not be_nil
        expect(no_computed_role).to be_nil
      end
    end

    it 'plays nice with a string role' do
      json_test_templates('lambda_function/lambda_function_with_string_role').each do |template|
        cfn_model = @cfn_parser.parse IO.read(template)

        actual_functions = cfn_model.resources_by_type('AWS::Lambda::Function')
        actual_computed_role = actual_functions.find do |function|
          function.role_id == 'arn:aws:iam::123456789012:role/LambdaExecutionRole'
        end
        no_computed_role = actual_functions.find do |function|
          function.role_id == 'WrongExecutionRole'
        end

        expect(actual_computed_role).to_not be_nil
        expect(no_computed_role).to be_nil
      end
    end
  end
end
