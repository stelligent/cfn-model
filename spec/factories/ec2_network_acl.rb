require 'cfn-model/model/ec2_network_acl'
require 'cfn-model/model/ec2_network_acl_entry'
require 'cfn-model/model/cfn_model'

def network_acl_with_one_entry(cfn_model: CfnModel.new, network_acl_id: 'myNetworkAcl',
                               network_acl_entry_id: 'EgressEntry1')
  network_acl_entry = AWS::EC2::NetworkAclEntry.new cfn_model
  network_acl_entry.portRange = { 'From' => '443', 'To' => '443' }
  network_acl_entry.logical_resource_id = network_acl_entry_id
  network_acl_entry.protocol = '6'
  network_acl_entry.ruleAction = 'allow'
  network_acl_entry.ruleNumber = '100'
  network_acl_entry.cidrBlock = '10.0.0.0/16'
  network_acl_entry.egress = true
  network_acl_entry.networkAclId = { 'Ref' => network_acl_id }
  network_acl_entry
end

def network_acl_with_two_entries(cfn_model: CfnModel.new, network_acl_id: 'myNetworkAcl',
                                 network_acl_entry_id1: 'EgressEntry1',
                                 network_acl_entry_id2: 'EgressEntry2')
  network_acl_entries = []
  network_acl_entry1 = AWS::EC2::NetworkAclEntry.new cfn_model
  network_acl_entry2 = AWS::EC2::NetworkAclEntry.new cfn_model
  network_acl_entry1.protocol = network_acl_entry2.protocol = '6'
  network_acl_entry1.ruleAction = network_acl_entry2.ruleAction = 'allow'
  network_acl_entry1.cidrBlock = network_acl_entry2.cidrBlock = '10.0.0.0/16'
  network_acl_entry1.egress = network_acl_entry2.egress = true
  network_acl_entry1.networkAclId = network_acl_entry2.networkAclId = { 'Ref' => network_acl_id }
  network_acl_entry1.portRange = { 'From' => '443', 'To' => '443' }
  network_acl_entry2.portRange = { 'From' => '80', 'To' => '80' }
  network_acl_entry1.logical_resource_id = network_acl_entry_id1
  network_acl_entry2.logical_resource_id = network_acl_entry_id2
  network_acl_entry1.ruleNumber = '100'
  network_acl_entry2.ruleNumber = '200'
  network_acl_entries << network_acl_entry1 << network_acl_entry2
  network_acl_entries
end
