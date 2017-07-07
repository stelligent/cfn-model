require 'spec_helper'
require 'validator/schema_generator'

describe SchemaGenerator do
  before(:each) do
    @schema_generator = SchemaGenerator.new
  end

  context 'a json template' do
    context 'an iam user with no groups' do
      it 'returns a user with no groups' do

        #puts @schema_generator.generate(IO.read('spec/test_templates/yaml/iam_user/iam_user_with_no_group.yml'))
      end
    end
  end
end
