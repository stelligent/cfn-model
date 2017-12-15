require 'spec_helper'
require 'cfn-model/parser/cfn_parser'

describe CfnParser do
  before :each do
    @cfn_parser = CfnParser.new
  end

  context 'when a topic name contains If' do
    it 'assigns the topicName to the Fn::If hash' do
      yaml_test_templates('sns_topic/topic_with_if').each do |test_template|
        cfn_model = @cfn_parser.parse IO.read(test_template)

        expect(cfn_model.resources_by_type('AWS::SNS::Topic').first.topicName).to eq({
                                                                                                   'Fn::If' => %w(cond1 bif zane)
                                                                                                 })
      end
    end
  end
end
