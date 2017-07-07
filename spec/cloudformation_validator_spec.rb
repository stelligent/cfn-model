require 'spec_helper'
require 'validator/cloudformation_validator'

describe CloudFormationValidator do
  before(:each) do
    @cfn_validator = CloudFormationValidator.new
  end

  context 'a json template' do
    context 'an iam user with no groups' do
      it 'returns a user with no groups' do

        # errors = @cfn_validator.validate(IO.read('spec/test_templates/yaml/iam_user/invalid_iam_user_with_one_group.yml'))
        # puts "errors: #{errors}"
      end
    end
  end
end
