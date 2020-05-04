require 'spec_helper'
require 'cfn-model/parser/cfn_parser'
require 'cfn-model/parser/parser_error'

describe CfnParser do
  before :each do
    @cfn_parser = CfnParser.new
  end

  context 'an iam role without an AssumeRolePolicy' do
    it 'raises an error' do
      test_templates('iam_role/iam_role_without_assume').each do |test_template|
        begin
          _ = @cfn_parser.parse IO.read(test_template)
        rescue Exception => parse_error
          begin
            expect(parse_error.is_a?(ParserError)).to eq true
            expect(parse_error.errors.size).to eq(1)
            expect(parse_error.errors[0].to_s).to eq("[/Resources/RootRole/Properties] key 'AssumeRolePolicyDocument:' is required.")
          rescue RSpec::Expectations::ExpectationNotMetError
            $!.message << "in file: #{test_template}"
            raise
          end
        end
      end
    end
  end

  context 'an iam role with signle statement' do
    it 'returns role with statements array of size 1' do
      test_templates('iam_role/iam_role_with_single_statement').each do |test_template|
        cfn_model = @cfn_parser.parse IO.read(test_template)

        roles = cfn_model.resources_by_type('AWS::IAM::Role')

        expect(roles.size).to eq 1
        role = roles.first

        expect(role).to eq iam_role_with_single_statement
      end
    end
  end

  context 'an iam role with embedded refs in a policy', :moo8 do
    it 'returns role with statements array of size 1' do
      yaml_test_templates('iam_role/embedded_ref').each do |test_template|
        cfn_model = @cfn_parser.parse IO.read(test_template), '{"Parameters":{"Resource":"*"}}'

        roles = cfn_model.resources_by_type('AWS::IAM::Role')

        expect(roles.size).to eq 1
        role = roles.first
        expect(role.policy_objects.first.policy_document.statements.first.resources.first).to eq '*'
      end
    end
  end
end