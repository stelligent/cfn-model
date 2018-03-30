require 'spec_helper'
require 'cfn-model/parser/cfn_parser'

describe CfnParser do
  before :each do
    @cfn_parser = CfnParser.new
  end

  context 'a template with a lambda permission' do
    it 'plays nice with computed principal' do
      json_test_templates('lambda_permission/lambda_permission_with_non_string_principal').each do |test_template|
        cfn_model = @cfn_parser.parse IO.read(test_template)


        actual_permissions = cfn_model.resources_by_type('AWS::Lambda::Permission')
        actual_computed_permission = actual_permissions.find do |permission|
          permission.principal == { 'Fn::Join' => ['-', %w(jim bob)] }
        end

        expect(actual_computed_permission).to_not be_nil
      end
    end
  end
end