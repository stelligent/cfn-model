require 'spec_helper'
require 'cfn-model/parser/cfn_parser'

describe CfnParser do
  before :each do
    @cfn_parser = CfnParser.new
  end

  context 'an iam user with no groups' do
    it 'returns a user with no groups' do
      test_templates('iam_user/iam_user_with_no_group').each do |test_template|
        expected_iam_user = iam_user_with_no_groups(cfn_model: CfnModel.new)
        cfn_model = @cfn_parser.parse IO.read(test_template)

        expect(cfn_model.iam_users.size).to eq 1
        expect(cfn_model.iam_users.first).to eq expected_iam_user
      end
    end
  end

  context 'an iam user with two groups' do
    it 'returns a user with two groups' do
      expected_iam_user = iam_user_with_two_groups(cfn_model: CfnModel.new)

      test_templates('iam_user/iam_user_with_two_groups').each do |test_template|
        cfn_model = @cfn_parser.parse IO.read(test_template)

        expect(cfn_model.iam_users.size).to eq 1
        expect(cfn_model.iam_users.first).to eq expected_iam_user
      end
    end
  end

  # context 'an iam user with invalid String group', :moo do
  #   it 'returns an error' do
  #     test_templates('iam_user/invalid_iam_user_with_one_group').each do |test_template|
  #       begin
  #         _ = @cfn_parser.parse IO.read(test_template)
  #       rescue Exception => parse_error
  #         begin
  #           expect(parse_error.is_a?(ParserError)).to eq true
  #           expect(parse_error.errors.size).to eq(1)
  #           expect(parse_error.errors[0].to_s).to eq("[/Resources/iamUserWithOneGroup/Properties/Groups] 'group1': not a sequence.")
  #         rescue RSpec::Expectations::ExpectationNotMetError
  #           $!.message << "in file: #{test_template}"
  #           raise
  #         end
  #       end
  #     end
  #   end
  # end

  context 'an iam user with four groups via addition' do
    it 'returns a user with four groups' do
      expected_iam_user = iam_user_with_two_groups_and_two_additions(cfn_model: CfnModel.new)

      test_templates('iam_user/iam_user_with_two_additions').each do |test_template|
        cfn_model = @cfn_parser.parse IO.read(test_template)

        expect(cfn_model.iam_users.size).to eq 1
        expect(cfn_model.iam_users.first).to eq expected_iam_user
      end
    end
  end

  context 'an iam user with four groups via addition' do
    it 'returns a user with four groups' do
      expected_iam_user = iam_user_with_one_addition(cfn_model: CfnModel.new)

      test_templates('iam_user/iam_user_with_literal_username_and_addition').each do |test_template|
        cfn_model = @cfn_parser.parse IO.read(test_template)

        expect(cfn_model.iam_users.size).to eq 1
        expect(cfn_model.iam_users.first).to eq expected_iam_user
      end
    end
  end

end