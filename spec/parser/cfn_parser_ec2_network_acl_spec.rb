require 'spec_helper'
require 'cfn-model/parser/cfn_parser'

describe CfnParser do
  before :each do
    @cfn_parser = CfnParser.new
  end

  context 'Network ACL that has one egress entry' do
    it 'returns a Network ACL with one entry' do
      yaml_test_templates('ec2_network_acl/nacl_with_one_entry').each do |test_template|
        cfn_model = @cfn_parser.parse IO.read(test_template)
        nacls = cfn_model.resources_by_type 'AWS::EC2::NetworkAcl'
        expect(nacls.size).to eq 1
        nacl = nacls.first
        expected_nacl_entries = network_acl_with_one_entry
        actual_network_acl_entries = nacl.network_acl_entries.first
        expect(actual_network_acl_entries).to eq expected_nacl_entries
      end
    end
  end

  context 'Network ACL that has two entries' do
    it 'returns a Network ACL with two entries' do
      yaml_test_templates('ec2_network_acl/nacl_with_two_entries').each do |test_template|
        cfn_model = @cfn_parser.parse IO.read(test_template)
        nacls = cfn_model.resources_by_type 'AWS::EC2::NetworkAcl'
        expect(nacls.size).to eq 1
        nacl = nacls.first
        expected_nacl_entries = network_acl_with_two_entries
        actual_network_acl_entries = nacl.network_acl_entries
        expected_nacl_entries.zip(actual_network_acl_entries).each do |expected, actual|
          expect(actual).to eq expected
        end
      end
    end
  end
end
