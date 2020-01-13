require 'spec_helper'
require 'cfn-model/parser/cfn_parser'
require 'cfn-model/parser/parser_error'

describe CfnParser do
  before :each do
    @cfn_parser = CfnParser.new
  end

  context 'a kms key without a KeyPolicy' do
    it 'raises an error' do
      test_templates('kms_key/kms_key_without_key_policy').each do |test_template|
        begin
          _ = @cfn_parser.parse IO.read(test_template)
        rescue Exception => parse_error
          begin
            expect(parse_error.is_a?(ParserError)).to eq true
            expect(parse_error.errors.size).to eq(1)
            expect(parse_error.errors[0].to_s).to eq("[/Resources/RootKey/Properties] key 'KeyPolicy:' is required.")
          rescue RSpec::Expectations::ExpectationNotMetError
            $!.message << "in file: #{test_template}"
            raise
          end
        end
      end
    end
  end

  context 'a kms key with a single statement' do
    it 'returns key with statements array of size 1' do
      test_templates('kms_key/kms_key_with_single_statement').each do |test_template|
        cfn_model = @cfn_parser.parse IO.read(test_template)

        keys = cfn_model.resources_by_type('AWS::KMS::Key')

        expect(keys.size).to eq 1
        key = keys.first

        expect(key).to eq kms_key_with_single_statement
      end
    end
  end
end
