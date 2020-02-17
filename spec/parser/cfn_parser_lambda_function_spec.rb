# frozen_string_literal: true

require 'spec_helper'
require 'cfn-model/parser/cfn_parser'

describe CfnParser do
  before :each do
    @cfn_parser = CfnParser.new
  end

  context 'a template with a lambda function' do
    it 'has assocated role_object when ref id' do
      json_test_templates('lambda_function/lambda_function_with_getatt_role').each do |template|
        cfn_model = @cfn_parser.parse IO.read(template)

        actual_functions = cfn_model.resources_by_type('AWS::Lambda::Function')
        actual_computed_role = actual_functions.find do |function|
          function.role_object
        end

        expect(actual_computed_role).to_not be_nil
      end
    end

    it 'does not have associated role_object when string id' do
      json_test_templates('lambda_function/lambda_function_with_string_role').each do |template|
        cfn_model = @cfn_parser.parse IO.read(template)

        actual_functions = cfn_model.resources_by_type('AWS::Lambda::Function')
        actual_computed_role = actual_functions.find do |function|
          function.role_object
        end

        expect(actual_computed_role).to be_nil
      end
    end
  end
end
