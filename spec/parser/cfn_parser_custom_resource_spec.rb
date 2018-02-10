require 'spec_helper'
require 'cfn-model/parser/cfn_parser'
require 'cfn-model/parser/parser_error'

describe CfnParser do
  before :each do
    @cfn_parser = CfnParser.new
  end

  context 'a template with a custom resource', :custom do
    it 'returns a Custom::TestCustomResourceWithLambda object' do
      yaml_test_templates('custom_resource/custom_resource').each do |test_template|
        cfn_model = @cfn_parser.parse IO.read(test_template)

        custom_resources = cfn_model.resources_by_type('Custom::TestCustomResourceWithLambda')

        expect(custom_resources.size).to eq 2
        actual_custom_resource = custom_resources.first
        expect(actual_custom_resource.serviceToken).to eq({
                                                                    'Fn::GetAtt' => %w(TestLambdaFunction Arn)
                                                                  })
      end
    end
  end
end