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

    it 'raises an error when JSON contains UTF-8 characters' do
      invalid_character_json = File.read(
        'spec/test_templates/json/template_with_utf8_characters.json'
      )

      expect do
        CloudFormationValidator.new.validate(invalid_character_json)
      end.to raise_error ParserError, /invalid byte sequence in US-ASCII/
    end

    it 'does not raise an error when JSON contains UTF-8 characters and ' \
       'read with correct encoding' do
      invalid_character_json = File.read(
        'spec/test_templates/json/template_with_utf8_characters.json',
        encoding: Encoding::UTF_8
      )

      expect(CloudFormationValidator.new.validate(invalid_character_json)).to eq []
    end

    it 'raises an error when YAML contains UTF-8 characters' do
      invalid_character_template = File.read(
        'spec/test_templates/yaml/template_with_utf8_characters.yml'
      )

      expect do
        CloudFormationValidator.new.validate(invalid_character_template)
      end.to raise_error ParserError, /invalid byte sequence in US-ASCII/
    end

    it 'does not raise an error when YAML contains UTF-8 characters and ' \
       'read with correct encoding' do
      invalid_character_template = File.read(
        'spec/test_templates/yaml/template_with_utf8_characters.yml',
        encoding: Encoding::UTF_8
      )

      expect(CloudFormationValidator.new.validate(invalid_character_template)).to eq []
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

  context 'YAML template' do
    it 'does not raise an error when template is YAML' do
      valid_yaml = <<-TEMPLATE
---
Resources:
  iamUserWithNoGroups:
    Type: "AWS::IAM::User"
TEMPLATE

      expect(CloudFormationValidator.new.validate(valid_yaml)).to eq []
    end

    it 'does not raise an error when template is YAML with embedded JSON' do
      valid_yaml = <<-TEMPLATE
---
Resources:
  TriggerPipelineRule:
    Type: AWS::Events::Rule
    Properties:
      Description: 'Triggers something'
      Name: SomethingTrigger
      ScheduleExpression: cron(0 12 ? * SAT *)
      State: ENABLED
      Targets:
        -
          Arn: DoesntMatter
          RoleArn: DoesntMatter
          Id: codebuild-something
          Input: >-
            {
              "environmentVariablesOverride": [
                {
                  "name": "NO_DRY_RUN",
                  "value": "true"
                }
              ]
            }
TEMPLATE

      expect(CloudFormationValidator.new.validate(valid_yaml)).to eq []
    end
  end
end
