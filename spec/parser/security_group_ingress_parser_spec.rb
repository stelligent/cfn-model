require 'spec_helper'
require 'parser/security_group_ingress_parser'
require 'model/security_group'
require 'model/security_group_ingress'
require 'parser/parser_error'

describe SecurityGroupIngressParser do
  before(:each) do
    @security_group_ingress_parser = SecurityGroupIngressParser.new
  end

  context 'a json template' do
    context 'a security group ingress with a string literal group id' do
      it 'returns a string ingress object' do
        security_group_ingresses = @security_group_ingress_parser.parse direct_model: direct_json_model(test_file: 'security_group_ingress/valid_standalone_ingress_with_literal_group_id.json')

        expect(security_group_ingresses.size).to eq 1
        security_group_ingress = security_group_ingresses.first

        expect(security_group_ingress.logical_resource_id).to eq 'securityGroupIngress1'
        expect(security_group_ingress.ipProtocol).to eq 'tcp'
        expect(security_group_ingress.cidrIp).to eq '10.1.2.3/32'
        expect(security_group_ingress.fromPort).to eq 34
        expect(security_group_ingress.toPort).to eq 36
        expect(security_group_ingress.groupId).to eq 'sg-29206a4f'
      end
    end

    context 'a security group ingress with no source specified', :foo do
      it 'raises an error' do
        expect {
          _ = @security_group_ingress_parser.parse direct_model: direct_json_model(test_file: 'security_group_ingress/no_source.json')
        }.to raise_error 'SG ingress noSourceSecurityGroupIngress has no source specified'
      end
    end

    context 'a security group ingress with missing from or to fields' do
      it 'raises an error' do
        expect {
          _ = @security_group_ingress_parser.parse direct_model: direct_json_model(test_file: 'security_group_ingress/missing_port.json')
        }.to raise_error 'SG ingress missingToPortSecurityGroupIngress missing protocol, from or to port'
      end
    end
    #
    # context 'a security group ingress with missing GroupId' do
    #   it 'returns a string ingress object' do
    #     expect {
    #       _ = @security_group_ingress_parser.parse direct_model: direct_json_model(test_file: 'security_group/xxxxx.json')
    #     }.to raise_error 'no source'
    #   end
    # end
    #
    # context 'a security group ingress with GroupName' do
    #   it 'returns a string ingress object' do
    #     expect {
    #       _ = @security_group_ingress_parser.parse direct_model: direct_json_model(test_file: 'security_group/xxxxx.json')
    #     }.to raise_error 'no source'
    #   end
    # end
    #
    # context 'a security group ingress with SourceSecurityGroupOwnerId' do
    #   it 'returns a string ingress object' do
    #     expect {
    #       _ = @security_group_ingress_parser.parse direct_model: direct_json_model(test_file: 'security_group/xxxxx.json')
    #     }.to raise_error 'no source'
    #   end
    # end
  end
end
