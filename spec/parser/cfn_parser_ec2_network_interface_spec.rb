require 'spec_helper'
require 'cfn-model/parser/cfn_parser'
require 'cfn-model/parser/parser_error'

describe CfnParser, :eni do
  before :each do
    @cfn_parser = CfnParser.new
  end

  context 'a network interface with external sg via Parameter' do
    it 'returns network interface with reference to Parameter' do
      yaml_test_templates('ec2_network_interface/interface_with_external_sg').each do |test_template|
        cfn_model = @cfn_parser.parse IO.read(test_template)

        network_interfaces = cfn_model.resources_by_type('AWS::EC2::NetworkInterface')

        expect(network_interfaces.size).to eq 1
        network_interface = network_interfaces.first

        expect(network_interface.groupSet.size).to eq 1
        expect(network_interface.groupSet.first).to eq ({ 'Ref' => 'CentrallyMaintainedSgId'})
      end
    end
  end

  context 'a network interface with no security group' do
    it 'returns network interface without security group' do
      yaml_test_templates('ec2_network_interface/interface_without_sg').each do |test_template|
        cfn_model = @cfn_parser.parse IO.read(test_template)

        network_interfaces = cfn_model.resources_by_type('AWS::EC2::NetworkInterface')

        expect(network_interfaces.size).to eq 1
        network_interface = network_interfaces.first

        expect(network_interface.groupSet.size).to eq 0
      end
    end
  end

  context 'a network interface with security group' do
    it 'returns network interface with security group' do
      yaml_test_templates('ec2_network_interface/interface_with_sg').each do |test_template|
        cfn_model = @cfn_parser.parse IO.read(test_template)

        network_interfaces = cfn_model.resources_by_type('AWS::EC2::NetworkInterface')

        expect(network_interfaces.size).to eq 1
        network_interface = network_interfaces.first

        expected_security_group = security_group_with_one_ingress_and_one_egress_rule

        actual_security_group = network_interface.security_groups.first
        expect(actual_security_group).to eq expected_security_group
      end
    end
  end
end