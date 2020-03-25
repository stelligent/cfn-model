require 'spec_helper'
require 'cfn-model/parser/cfn_parser'

describe CfnParser do
  before :each do
    @cfn_parser = CfnParser.new
  end

  context 'Network ACL that has one egress entry' do
    it 'returns a Network ACL with one egress entry' do
      expected_nacls = network_acl_with_one_egress_entry(cfn_model: CfnModel.new)
      yaml_test_templates('ec2_network_acl/nacl_with_one_egress_entry').each do |test_template|
        cfn_model = @cfn_parser.parse IO.read(test_template)
        nacls = cfn_model.resources_by_type 'AWS::EC2::NetworkAcl'

        expect(nacls.size).to eq 1
        expect(nacls[0]).to eq expected_nacls
        expect(nacls[0].network_acl_egress_entries).to eq expected_nacls.network_acl_egress_entries
        expect(nacls[0].network_acl_egress_entries).not_to be_empty
      end
    end
  end

  context 'Network ACL that has one ingress entry' do
    it 'returns a Network ACL with one ingress entry' do
      expected_nacls = network_acl_with_one_ingress_entry(cfn_model: CfnModel.new)
      yaml_test_templates('ec2_network_acl/nacl_with_one_ingress_entry').each do |test_template|
        cfn_model = @cfn_parser.parse IO.read(test_template)
        nacls = cfn_model.resources_by_type 'AWS::EC2::NetworkAcl'

        expect(nacls.size).to eq 1
        expect(nacls[0]).to eq expected_nacls
        expect(nacls[0].network_acl_ingress_entries).to eq expected_nacls.network_acl_ingress_entries
        expect(nacls[0].network_acl_ingress_entries).not_to be_empty
      end
    end
  end

  context 'Network ACL that has two egress entries' do
    it 'returns a Network ACL with two egress entries' do
      expected_nacls = network_acl_with_two_egress_entries(cfn_model: CfnModel.new)
      yaml_test_templates('ec2_network_acl/nacl_with_two_egress_entries').each do |test_template|
        cfn_model = @cfn_parser.parse IO.read(test_template)
        nacls = cfn_model.resources_by_type 'AWS::EC2::NetworkAcl'

        expect(nacls.size).to eq 1
        expect(nacls[0]).to eq expected_nacls
        expect(nacls[0].network_acl_egress_entries).to eq expected_nacls.network_acl_egress_entries
        expect(nacls[0].network_acl_egress_entries).not_to be_empty
      end
    end
  end

  context 'Network ACL that has two ingress entries' do
    it 'returns a Network ACL with two ingress entries' do
      expected_nacls = network_acl_with_two_ingress_entries(cfn_model: CfnModel.new)
      yaml_test_templates('ec2_network_acl/nacl_with_two_ingress_entries').each do |test_template|
        cfn_model = @cfn_parser.parse IO.read(test_template)
        nacls = cfn_model.resources_by_type 'AWS::EC2::NetworkAcl'

        expect(nacls.size).to eq 1
        expect(nacls[0]).to eq expected_nacls
        expect(nacls[0].network_acl_ingress_entries).to eq expected_nacls.network_acl_ingress_entries
        expect(nacls[0].network_acl_ingress_entries).not_to be_empty
      end
    end
  end
  context 'Network ACL that has one egress and ingress entry' do
    it 'returns a Network ACL with one egress and ingress entry' do
      expected_nacls = network_acl_with_egress_and_ingress_entries(cfn_model: CfnModel.new)
      yaml_test_templates('ec2_network_acl/nacl_with_one_egress_and_ingress_entry').each do |test_template|
        cfn_model = @cfn_parser.parse IO.read(test_template)
        nacls = cfn_model.resources_by_type 'AWS::EC2::NetworkAcl'

        expect(nacls.size).to eq 1
        expect(nacls[0]).to eq expected_nacls
        expect(nacls[0].network_acl_egress_entries).to eq expected_nacls.network_acl_egress_entries
        expect(nacls[0].network_acl_ingress_entries).to eq expected_nacls.network_acl_ingress_entries
        expect(nacls[0].network_acl_egress_entries).not_to be_empty
        expect(nacls[0].network_acl_ingress_entries).not_to be_empty
      end
    end
  end
end
