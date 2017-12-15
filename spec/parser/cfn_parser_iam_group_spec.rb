require 'spec_helper'
require 'cfn-model/parser/cfn_parser'

describe CfnParser do
  before :each do
    @cfn_parser = CfnParser.new
  end

  context 'an iam group with no policies' do
    it 'returns a group with no policies' do
      yaml_test_templates('iam_group/iam_group_with_no_policies').each do |test_template|
        expected_iam_group = iam_group_with_no_policies
        cfn_model = @cfn_parser.parse IO.read(test_template)

        expect(cfn_model.resources_by_type('AWS::IAM::Group').size).to eq 1
        expect(cfn_model.resources_by_type('AWS::IAM::Group').first).to eq expected_iam_group
      end
    end
  end

  context 'an iam group with policies' do
    it 'returns a group with policies' do
      yaml_test_templates('iam_group/iam_group_with_policies').each do |test_template|
        expected_iam_group = iam_group_with_policies
        cfn_model = @cfn_parser.parse IO.read(test_template)

        expect(cfn_model.resources_by_type('AWS::IAM::Group').size).to eq 1
        expect(cfn_model.resources_by_type('AWS::IAM::Group').first).to eq expected_iam_group
      end
    end
  end

  context 'when an iam group contains a policy that is an If' do
    it 'maps the Fn::If to a hash' do
      yaml_test_templates('iam_group/iam_group_with_if').each do |test_template|
        cfn_model = @cfn_parser.parse IO.read(test_template)
        puts cfn_model


        expect(cfn_model.resources_by_type('AWS::IAM::Group').first.policies.first).to eq({
                                                                                       'Fn::If' => [
                                                                                         'OtherPolicy',
                                                                                         {
                                                                                           'PolicyDocument' => {
                                                                                             'Statement' => {
                                                                                               'Effect' => 'Allow',
                                                                                               'Action' => '*',
                                                                                               'Resource' => '*'
                                                                                             }
                                                                                           },
                                                                                           'PolicyName' => 'jimbob'
                                                                                         },
                                                                                         {
                                                                                           'Ref' => 'AWS::NoValue'
                                                                                         }
                                                                                       ]
                                                                                     })
      end
    end
  end
end
