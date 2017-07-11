require 'spec_helper'
require 'cfn-model/validator/schema_generator'

describe SchemaGenerator do
  before(:each) do
    @schema_generator = SchemaGenerator.new
  end

  context 'cfn template with iam user' do
    it 'returns a Hash that can be used as a kwalify schema' do

      actual_schema_hash = @schema_generator.generate(IO.read('spec/test_templates/yaml/iam_user/iam_user_with_no_group.yml'))

      expected_iam_user_schema_hash = {
        'type' => 'map',
        'mapping' => {
          'Type' => {
            'type' => 'str',
            'required' => true,
            'pattern' => '/AWS::IAM::User/'
          },
          'Properties' => {
            'type' => 'map',
            'mapping' => {
              'Groups' => {
                'type' =>   'seq',
                'required' => false,
                'sequence' => [
                  {
                    'type' =>   'any'
                  }
                ]
              },
              'LoginProfile' => {
                'type' => 'map',
                'required' =>false,
                'mapping' => {
                  'Password' => {
                    'type' => 'any',
                    'required' => true
                  },
                  '=' => {
                    'type' => 'any'
                  }
                }
              },
              'ManagedPolicyArns' => {
                'type' => 'seq',
                'required' => false,
                'sequence' => [
                  {
                    'type' => 'any'
                  }
                ]
              },
              'Policies' => {
                'type' => 'seq',
                'required' => false,
                'sequence' => [
                  {
                    'type' => 'any'
                  }
                ]
              },
              '=' => {
                'type' =>  'any'
              }
            }
          },
          '=' => {
            'type' => 'any'
          }
        }
      }

      expected_schema_hash = {
        'type' => 'map',
        'mapping' => {
          'Resources' => {
            'type' => 'map',
            'required' => true,
            'mapping' => {
              'iamUserWithNoGroups' => expected_iam_user_schema_hash,
              '=' => {
                'type' => 'any'
              }
            }
          },
          '=' => {
            'type' => 'any'
          }
        }
      }
      expect(actual_schema_hash).to eq expected_schema_hash
    end
  end
end
