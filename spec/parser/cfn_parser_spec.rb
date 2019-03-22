require 'spec_helper'
require 'cfn-model/parser/cfn_parser'

describe CfnParser do
  before :each do
    @cfn_parser = CfnParser.new
  end

  context 'a yml template' do
    context 'an empty template' do
      it 'returns a parse error' do
        expect {
          @cfn_parser.parse('')
        }.to raise_error 'yml empty'

        expect {
          @cfn_parser.parse('---')
        }.to raise_error 'yml empty'
      end
    end

    context 'a template with missing Resources' do
      it 'returns a parse error' do

        expect {
          @cfn_parser.parse <<END
---
Parameters: {}
END
        }.to raise_error 'Illegal cfn - no Resources'

      end
    end

    context 'a template with empty Resources' do
      it 'returns a parse error' do
        expect {
          @cfn_parser.parse <<END
---
Parameters: {}
Resources: {}
END
        }.to raise_error 'Illegal cfn - no Resources'
      end
    end
  end

  context 'a json template' do
    context 'an empty template' do
      it 'returns a parse error' do
        expect {
          @cfn_parser.parse('')
        }.to raise_error 'yml empty'

        expect {
          @cfn_parser.parse('{}')
        }.to raise_error 'Illegal cfn - no Resources'
      end
    end

    context 'a template with missing Resources' do
      it 'returns a parse error' do

        expect {
          @cfn_parser.parse <<END
{
  "Parameters": {}
}
END
        }.to raise_error 'Illegal cfn - no Resources'

      end
    end

    context 'a template with unforeseen resource type' do
      it 'creates a dynamic object on the fly' do
        cloudformation_yml = <<END
---
Resources:
  newResource:
    Type: "AWS::TimeTravel::Machine"
    Properties:
      Fuel: dilithium
END
        cfn_model = @cfn_parser.parse cloudformation_yml

        expect(cfn_model.resources.size).to eq 1

        time_travel_machine = cfn_model.resources_by_type('AWS::TimeTravel::Machine').first
        expect(time_travel_machine.is_a?(ModelElement)).to eq true
        expect(time_travel_machine.fuel).to eq 'dilithium'
      end
    end

    context 'a template with empty Resources' do
      it 'returns a parse error' do
        expect {
          @cfn_parser.parse <<END
{
"Parameters": {},
"Resources": {}
}
END
        }.to raise_error 'Illegal cfn - no Resources'
      end
    end
  end

  context 'template with parameters' do
    it 'returns model with parameters' do
      cloudformation_template_yml = IO.read(yaml_test_templates('ec2_instance/instance_with_sgid_list_ref').first)
      actual_cfn_model = @cfn_parser.parse cloudformation_template_yml

      expect(actual_cfn_model.parameters['SubnetId'].type).to eq 'AWS::EC2::Subnet::Id'
      expect(actual_cfn_model.parameters['SgIds'].type).to eq 'List<AWS::EC2::SecurityGroup::Id>'
      expect(actual_cfn_model.parameters['SgIds'].is_no_echo?).to_not eq true
      expect(actual_cfn_model.parameters['Password'].is_no_echo?).to eq true
    end
  end

  context 'template with external parameter values' do
    it 'returns model with parameter values resolved' do

      parameters_json = <<END
{      
  "Parameters": {
    "SubnetId": "subnet-1234",
    "SgIds": "sg-1234, sg-4566",
    "Password": "thisisbad"
  }
}
END
      cloudformation_template_yml = IO.read(yaml_test_templates('ec2_instance/instance_with_sgid_list_ref').first)
      actual_cfn_model = @cfn_parser.parse cloudformation_template_yml, parameters_json

      expect(actual_cfn_model.parameters['SubnetId'].synthesized_value).to eq 'subnet-1234'
      expect(actual_cfn_model.parameters['VpcId'].synthesized_value).to eq 'vpc-e91e8490'

      expect(actual_cfn_model.resources['ec2Instance'].subnetId).to eq 'subnet-1234'
    end
  end

  context 'template with external parameter values in incorrect format - json array' do
    it 'raises a JSON::ParserError' do

      parameters_json = <<END
[
  {
    "ParameterKey": "SubnetId",
    "ParameterValue": "sg-1234"
  }
]
END
      cloudformation_template_yml = IO.read(yaml_test_templates('ec2_instance/instance_with_sgid_list_ref').first)

      expect {
        actual_cfn_model = @cfn_parser.parse cloudformation_template_yml, parameters_json
      }.to raise_error JSON::ParserError
    end
  end

  context 'template with external parameter values in incorrect format - missing key' do
    it 'raises a JSON::ParserError' do

      parameters_json = <<END
{
  "Parms": {
    "x": "y"
  }
}
END
      cloudformation_template_yml = IO.read(yaml_test_templates('ec2_instance/instance_with_sgid_list_ref').first)

      expect {
        actual_cfn_model = @cfn_parser.parse cloudformation_template_yml, parameters_json
      }.to raise_error JSON::ParserError
    end
  end

  context 'template with external parameter values in incorrect format - mangled JSON' do
    it 'raises a JSON::ParserError' do

      parameters_json = <<END
this isn't JSON really
END
      cloudformation_template_yml = IO.read(yaml_test_templates('ec2_instance/instance_with_sgid_list_ref').first)

      expect {
        actual_cfn_model = @cfn_parser.parse cloudformation_template_yml, parameters_json
      }.to raise_error JSON::ParserError
    end
  end
end
