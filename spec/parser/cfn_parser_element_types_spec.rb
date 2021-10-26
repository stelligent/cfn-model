require 'spec_helper'
require 'cfn-model/parser/cfn_parser'

describe CfnParser do
  before :each do
    @cfn_parser = CfnParser.new
  end

  context 'element types enabled' do
    it 'returns model with element_types for each resource' do
      cloudformation_template_yml = IO.read(yaml_test_templates('iam_user/iam_user_with_literal_username_and_addition').first)
      actual_cfn_model = @cfn_parser.parse cloudformation_template_yml, nil, true
      expected_element_types = {
        "AccessKey" => "parameter",
        "iamUserWithAddition" => "resource",
        "groupA" => "resource",
        "addition1" => "resource",
        "addition2" => "resource"
      }
      expect(actual_cfn_model.element_types).to eq expected_element_types
    end
  end
end
