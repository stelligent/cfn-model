require 'spec_helper'
require 'cfn-model/parser/cfn_parser'
require 'cfn-model/parser/parser_error'

describe CfnParser do
  before :each do
    @cfn_parser = CfnParser.new
  end

  context 'an ec2 instance with security group', :ec2 do
    it 'returns ec2 instance with security group' do
      yaml_test_templates('ec2_instance/instance_with_sg').each do |test_template|
        cfn_model = @cfn_parser.parse IO.read(test_template)

        ec2_instances = cfn_model.resources_by_type('AWS::EC2::Instance')
        expect(ec2_instances.size).to eq 1

        ec2_instance = ec2_instances.first
        expected_security_group = security_group_with_one_ingress_and_one_egress_rule
        actual_security_group = ec2_instance.security_groups.first
        expect(actual_security_group).to eq expected_security_group
      end
    end
  end

  context 'an ec2 instance with a ref to a list of security group ids', :ec2 do
    it 'returns ec2 instance with security group' do
      yaml_test_templates('ec2_instance/instance_with_sgid_list_ref').each do |test_template|
        cfn_model = @cfn_parser.parse IO.read(test_template)

        ec2_instances = cfn_model.resources_by_type('AWS::EC2::Instance')
        expect(ec2_instances.size).to eq 1

        ec2_instance = ec2_instances.first
        expect(ec2_instance.security_groups.size).to eq 0
      end
    end
  end

  context 'an ec2 instance with a launch template', :ec2 do
    it 'returns ec2 instance with launch template' do
      yaml_test_templates('ec2_instance/instance_with_launch_template').each do |test_template|
        cfn_model = @cfn_parser.parse IO.read(test_template)

        ec2_launch_templates = cfn_model.resources_by_type('AWS::EC2::LaunchTemplate')
        expect(ec2_launch_templates.size).to eq 1

        ec2_instances = cfn_model.resources_by_type('AWS::EC2::Instance')
        expect(ec2_instances.size).to eq 1
        expect(ec2_instances[0].launchTemplate).not_to be_empty
        expect(ec2_instances[0].imageId).to be_nil
      end
    end
  end
end
