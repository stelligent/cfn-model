require 'spec_helper'
require 'cfn-model/parser/parameter_substitution'
require 'cfn-model/parser/cfn_parser'

describe ParameterSubstitution do

  context 'legacy format' do
    it 'applies the parameter values' do
      parameters_json = <<-END
      {      
        "Parameters": {
          "SubnetId": "subnet-1234",
          "SgIds": "sg-1234, sg-4566",
          "Password": "thisisbad"
        }
      }
      END

      cfn_parser = CfnParser.new
      cfn_yml = IO.read(yaml_test_templates('ec2_instance/instance_with_sgid_list_ref').first)
      cfn_model = cfn_parser.parse_without_parameters cfn_yml

      ParameterSubstitution.new.apply_parameter_values cfn_model, parameters_json

      expect(cfn_model.parameters['SubnetId'].synthesized_value).to eq 'subnet-1234'
      expect(cfn_model.parameters['SgIds'].synthesized_value).to eq 'sg-1234, sg-4566'
      expect(cfn_model.parameters['VpcId'].synthesized_value).to eq 'vpc-e91e8490'
      expect(cfn_model.parameters['Password'].synthesized_value).to eq 'thisisbad'
      expect(cfn_model.resources['ec2Instance'].subnetId).to eq 'subnet-1234'
    end
  end

  context 'unknown format' do
    it 'raises an error' do
      parameters_json = <<-END
      {"garbage":"foo"}
      END
      cfn_parser = CfnParser.new
      cfn_yml = IO.read(yaml_test_templates('ec2_instance/instance_with_sgid_list_ref').first)
      cfn_model = cfn_parser.parse_without_parameters cfn_yml

      expect {
        ParameterSubstitution.new.apply_parameter_values cfn_model, parameters_json
      }.to raise_error(JSON::ParserError, 'JSON parameters must be a dictionary with key "Parameters" or an array of ParameterKey/ParameterValue dictionaries')
    end
  end

  context 'aws format - happy' do
    it 'applies the parameter values' do
      parameters_json = <<-END
      [
        {
          "ParameterKey": "SubnetId",
          "ParameterValue": "subnet-1234"
        },
        {
          "ParameterKey": "SgIds",
          "ParameterValue": "sg-1234, sg-4566"
        },
        {
          "ParameterKey": "Password",
          "ParameterValue": "thisisbad"
        }
      ]
    END
      cfn_parser = CfnParser.new
      cfn_yml = IO.read(yaml_test_templates('ec2_instance/instance_with_sgid_list_ref').first)
      cfn_model = cfn_parser.parse_without_parameters cfn_yml

      ParameterSubstitution.new.apply_parameter_values cfn_model, parameters_json

      expect(cfn_model.parameters['SubnetId'].synthesized_value).to eq 'subnet-1234'
      expect(cfn_model.parameters['SgIds'].synthesized_value).to eq 'sg-1234, sg-4566'
      expect(cfn_model.parameters['VpcId'].synthesized_value).to eq 'vpc-e91e8490'
      expect(cfn_model.parameters['Password'].synthesized_value).to eq 'thisisbad'
      expect(cfn_model.resources['ec2Instance'].subnetId).to eq 'subnet-1234'
    end

  end

  context 'aws format - mangled - missing ParameterKey' do
    it 'raises an error' do
      parameters_json = <<-END
      [
        {
          "ParameterValue": "subnet-1234"
        },
        {
          "ParameterKey": "SgIds",
          "ParameterValue": "sg-1234, sg-4566"
        },
        {
          "ParameterKey": "Password",
          "ParameterValue": "thisisbad"
        }
      ]
      END
      cfn_parser = CfnParser.new
      cfn_yml = IO.read(yaml_test_templates('ec2_instance/instance_with_sgid_list_ref').first)
      cfn_model = cfn_parser.parse_without_parameters cfn_yml

      expect {
        ParameterSubstitution.new.apply_parameter_values cfn_model, parameters_json
      }.to raise_error(JSON::ParserError, 'JSON parameters must be a dictionary with key "Parameters" or an array of ParameterKey/ParameterValue dictionaries')
    end
  end
  context 'aws format - mangled - missing ParameterKey' do
    it 'raises an error' do
      parameters_json = <<-END
      [
        {
          "ParameterKey": "SubnetId"
        },
        {
          "ParameterKey": "SgIds",
          "ParameterValue": "sg-1234, sg-4566"
        },
        {
          "ParameterKey": "Password",
          "ParameterValue": "thisisbad"
        }
      ]
      END
      cfn_parser = CfnParser.new
      cfn_yml = IO.read(yaml_test_templates('ec2_instance/instance_with_sgid_list_ref').first)
      cfn_model = cfn_parser.parse_without_parameters cfn_yml

      expect {
        ParameterSubstitution.new.apply_parameter_values cfn_model, parameters_json
      }.to raise_error(JSON::ParserError, 'JSON parameters must be a dictionary with key "Parameters" or an array of ParameterKey/ParameterValue dictionaries')
    end
  end
  context 'template with external parameter values' do
    it 'returns model with parameter values resolved' do


    end
  end

#   context 'template with external parameter values in incorrect format - json array' do
#     it 'raises a JSON::ParserError' do
#
#       cloudformation_template_yml = IO.read(yaml_test_templates('ec2_instance/instance_with_sgid_list_ref').first)
#
#       expect {
#         actual_cfn_model = @cfn_parser.parse cloudformation_template_yml, parameters_json
#       }.to raise_error JSON::ParserError
#     end
#   end
# #
#   context 'template with external parameter values in incorrect format - missing key' do
#     it 'raises a JSON::ParserError' do
#
#       parameters_json = <<END
# {
#   "Parms": {
#     "x": "y"
#   }
# }
# END
#       cloudformation_template_yml = IO.read(yaml_test_templates('ec2_instance/instance_with_sgid_list_ref').first)
#
#       expect {
#         actual_cfn_model = @cfn_parser.parse cloudformation_template_yml, parameters_json
#       }.to raise_error JSON::ParserError
#     end
#   end
#
#   context 'template with external parameter values in incorrect format - mangled JSON' do
#     it 'raises a JSON::ParserError' do
#
#       parameters_json = <<END
# this isn't JSON really
# END
#       cloudformation_template_yml = IO.read(yaml_test_templates('ec2_instance/instance_with_sgid_list_ref').first)
#
#       expect {
#         actual_cfn_model = @cfn_parser.parse cloudformation_template_yml, parameters_json
#       }.to raise_error JSON::ParserError
#     end
#   end
end