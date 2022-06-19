require 'spec_helper'
require 'cfn-model/validator/resource_type_validator'

describe ResourceTypeValidator do
  before(:each) do
    @resource_type_validator = ResourceTypeValidator.new
  end

  context 'empty template' do
    it 'raises an error' do
      expect {
        ResourceTypeValidator.validate ''
      }.to raise_error 'yml empty'
    end
  end

  context 'no Resources' do
    it 'raises an error' do
      expect {
        ResourceTypeValidator.validate <<END
---      
Fred:
  wilma: 5
END
      }.to raise_error 'Illegal cfn - no Resources'
    end

    context 'just an array' do
      it 'raises an error' do
        expect {
          ResourceTypeValidator.validate <<END
[
  "something",
  "tricky"
]
END
        }.to raise_error 'Illegal cfn - no Resources'
      end
    end
  end

  context 'empty Resources' do
    it 'raises an error' do
      expect {
        ResourceTypeValidator.validate <<END
---      
Resources: {}
END
      }.to raise_error 'Illegal cfn - no Resources'
    end
  end

  context 'resource with missing Type' do
    it 'raises an error' do
      expect {
        ResourceTypeValidator.validate <<END
---      
Resources:
  someResource:
    Properties:
      Fred: wilma
END
      }.to raise_error 'Illegal cfn - missing Type: id: someResource'
    end
  end

  context 'parameter with missing Type' do
    it 'raises an error' do
      expect {
        ResourceTypeValidator.validate <<END
---      
Parameters:
  someParameter:
    Properties:
      Fred: wilma

Resources:
  someResource:
    Type: AWS::WAF::WebAcl
    Properties:
      Heathcliff: Marmaduke
END
      }.to raise_error 'Illegal cfn - missing Parameter Type: id: someParameter'
    end
  end

  context 'all resources and parameters have types' do
    it 'returns the Hash of the parsed document' do
      actual_hash = ResourceTypeValidator.validate <<END
---      
Parameters:
  someParameter:
    Type: String
    Properties:
      Fred: wilma

Resources:
  someResource:
    Type: AWS::WAF::WebAcl
    Properties:
      Heathcliff: Marmaduke
END

      expected_hash = {
        'Parameters' => {
          'someParameter' => {
            'Type' => 'String',
            'Properties' => {
              'Fred' => 'wilma'
            }
          }
        },
        'Resources' => {
          'someResource' => {
            'Type' => 'AWS::WAF::WebAcl',
            'Properties' => {
              'Heathcliff' => 'Marmaduke'
            }
          }
        }
      }

      expect(actual_hash).to eq expected_hash
    end
  end

  context 'given a template with date and symbol values' do
    let(:template) { <<~TEMPLATE }
      ---      
      AWSTemplateFormatVersion: 2010-09-09
      Resources:
        SecurityGroupIngress:
          Type: AWS::EC2::SecurityGroupIngress
          Properties:
            GroupId: sg-12341234
            CidrIpv6: ::/0
            FromPort: 22
            ToPort: 22
            IpProtocol: tcp
    TEMPLATE

    it 'successfully returns the Hash of the parsed document' do
      parsed_template = ResourceTypeValidator.validate(template)

      expect(parsed_template).to eq(
        {
          'AWSTemplateFormatVersion' => Date.new(2010, 9, 9),
          'Resources' => {
            'SecurityGroupIngress' => {
              'Type' => 'AWS::EC2::SecurityGroupIngress',
              'Properties' => {
                'GroupId' => 'sg-12341234',
                'CidrIpv6' => :':/0',
                'FromPort' => 22,
                'ToPort' => 22,
                'IpProtocol' => 'tcp'
              }
            }
          }
        }
      )
    end
  end
end
