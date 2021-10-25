require 'spec_helper'
require 'cfn-model/parser/cfn_parser'

describe CfnParser do
  before :each do
    @cfn_parser = CfnParser.new
  end

  context 'line numbers enabled' do
    it 'returns model with line numbers for each resource' do
      cloudformation_template_yml = IO.read(yaml_test_templates('iam_user/iam_user_with_literal_username_and_addition').first)
      actual_cfn_model = @cfn_parser.parse cloudformation_template_yml, nil, true
      expected_line_numbers = {
        "AccessKey" => 4,
        "iamUserWithAddition" => 8,
        "groupA" => 13,
        "addition1" => 18,
        "addition2" => 28
      }
      expect(actual_cfn_model.line_numbers).to eq expected_line_numbers
    end
  end
end
