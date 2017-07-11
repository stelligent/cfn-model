require 'spec_helper'
require 'cfn-model/parser/cfn_parser'
require 'cfn-model/parser/parser_error'

describe CfnParser do
  before :each do
    @cfn_parser = CfnParser.new
  end

  context 'a s3 bucket policy missing properties' do
    it 'raises an error' do
      test_templates('s3_bucket_policy/bucket_policy_missing_properties').each do |test_template|
        begin
          _ = @cfn_parser.parse IO.read(test_template)
        rescue Exception => parse_error
          begin
            expect(parse_error.is_a?(ParserError)).to eq true
            expect(parse_error.errors.size).to eq(2)
            expect(parse_error.errors[0].to_s).to eq("[/Resources/S3BucketPolicy/Properties] key 'PolicyDocument:' is required.")
            expect(parse_error.errors[1].to_s).to eq("[/Resources/S3BucketPolicy/Properties] key 'Bucket:' is required.")
          rescue RSpec::Expectations::ExpectationNotMetError
            $!.message << "in file: #{test_template}"
            raise
          end
        end
      end
    end
  end

  context 'a valid s3 bucket policy' do
    it 'returns bucket policy' do
      test_templates('s3_bucket_policy/valid_bucket_policy').each do |test_template|
        cfn_model = @cfn_parser.parse IO.read(test_template)
        bucket_policies = cfn_model.resources_by_type('AWS::S3::BucketPolicy')
        expect(bucket_policies.size).to eq 1
        bucket_policy = bucket_policies.first

        expect(bucket_policy).to eq valid_bucket_policy
      end
    end
  end
end