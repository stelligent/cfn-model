require 'cfn-model/model/ec2_network_acl'
require 'cfn-model/model/cfn_model'

def network_acl_with_one_egress_entry(cfn_model: CfnModel.new)
  network_acl = AWS::EC2::NetworkAcl.new cfn_model
  network_acl.vpcId = 'testvpc1'
  network_acl.network_acl_egress_entries << 'EgressEntry1'
  network_acl
end

def network_acl_with_two_egress_entries(cfn_model: CfnModel.new)
  network_acl = AWS::EC2::NetworkAcl.new cfn_model
  network_acl.vpcId = 'testvpc1'
  %w[EgressEntry1 EgressEntry2].each do |egress_entry|
    network_acl.network_acl_egress_entries << egress_entry
  end
  network_acl
end

def network_acl_with_one_ingress_entry(cfn_model: CfnModel.new)
  network_acl = AWS::EC2::NetworkAcl.new cfn_model
  network_acl.vpcId = 'testvpc1'
  network_acl.network_acl_ingress_entries << 'IngressEntry1'
  network_acl
end

def network_acl_with_two_ingress_entries(cfn_model: CfnModel.new)
  network_acl = AWS::EC2::NetworkAcl.new cfn_model
  network_acl.vpcId = 'testvpc1'
  %w[IngressEntry1 IngressEntry2].each do |ingress_entry|
    network_acl.network_acl_ingress_entries << ingress_entry
  end
  network_acl
end

def network_acl_with_egress_and_ingress_entries(cfn_model: CfnModel.new)
  network_acl = AWS::EC2::NetworkAcl.new cfn_model
  network_acl.vpcId = 'testvpc1'
  network_acl.network_acl_egress_entries << 'EgressEntry1'
  network_acl.network_acl_ingress_entries << 'IngressEntry1'
  network_acl
end
