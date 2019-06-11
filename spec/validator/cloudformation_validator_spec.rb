require 'spec_helper'
require 'cfn-model/validator/cloudformation_validator'

describe CloudFormationValidator do

  context 'JSON template' do
    it 'raises an error when JSON is invalid' do
      invalid_json = <<-TEMPLATE
      {
        "AWSTemplateFormatVersion": "2010-09-09",
        "Resources": {
          "RootRole": {
            "Type": "AWS::IAM::Role",
            "Properties": {
              "AssumeRolePolicyDocument": {
                "Version" : "2012-10-17",
                "Statement": {
                  "Effect": "Allow",
                  "Principal": {
                    "Service": [ "ec2.amazonaws.com" ],
                    "AWS" : "arn:aws:iam::324320755747:root"
                  },
                  "Action": ["sts:AssumeRole"]
                }
              },
              "Path": "/",
              "Policies": [
                {
                  "PolicyName": "root",
                  "PolicyDocument": {
                    "Version" : "2012-10-17",
                    "Statement": {
                      "Effect": "Allow",
                      "Action": "*",
                      "Resource": "*"
                    }
                  }
              }
              ]
            },
          }
        }
      }
TEMPLATE

      [invalid_json, '{random text}'].each do |template_body|
        expect {
          CloudFormationValidator.new.validate(template_body)
        }.to raise_error 'Invalid JSON!'
      end
    end

    it 'does not raise an error when JSON is valid' do
      valid_json = <<-TEMPLATE
      {
        "AWSTemplateFormatVersion": "2010-09-09",
        "Resources": {
          "RootRole": {
            "Type": "AWS::IAM::Role",
            "Properties": {
              "AssumeRolePolicyDocument": {
                "Version" : "2012-10-17",
                "Statement": {
                  "Effect": "Allow",
                  "Principal": {
                    "Service": [ "ec2.amazonaws.com" ],
                    "AWS" : "arn:aws:iam::324320755747:root"
                  },
                  "Action": ["sts:AssumeRole"]
                }
              },
              "Path": "/",
              "Policies": [
                {
                  "PolicyName": "root",
                  "PolicyDocument": {
                    "Version" : "2012-10-17",
                    "Statement": {
                      "Effect": "Allow",
                      "Action": "*",
                      "Resource": "*"
                    }
                  }
              }
              ]
            }
          }
        }
      }
TEMPLATE

      expect(CloudFormationValidator.new.validate(valid_json)).to eq []
    end
  end
end
