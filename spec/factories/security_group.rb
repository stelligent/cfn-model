require 'cfn-model/model/security_group'
require 'cfn-model/model/security_group_ingress'
require 'cfn-model/model/cfn_model'

def security_group_with_one_ingress_rule(cfn_model: CfnModel.new, security_group_id: 'sg2', ingress_group_id: nil)
  ingress_rule = AWS::EC2::SecurityGroupIngress.new cfn_model
  ingress_rule.cidrIp = '10.1.2.3/32'
  ingress_rule.fromPort = 34
  ingress_rule.toPort = 36
  ingress_rule.ipProtocol = 'tcp'
  ingress_rule.groupId = ingress_group_id

  expected_security_group = AWS::EC2::SecurityGroup.new cfn_model
  expected_security_group.vpcId = { 'Ref' => 'VpcId' }
  expected_security_group.groupDescription = 'some_group_desc'
  expected_security_group.logical_resource_id = security_group_id
  expected_security_group.ingresses << ingress_rule
  expected_security_group.securityGroupIngress += [{
    'CidrIp' => '10.1.2.3/32',
    'FromPort' => 34,
    'ToPort' => 36,
    'IpProtocol' => 'tcp'
  }]

  yield expected_security_group, ingress_rule if block_given?
  expected_security_group
end

def security_group_with_one_ingress_rule_ipprotocol(cfn_model: CfnModel.new, security_group_id: 'sg3', ingress_group_id: nil)
  ingress_rule = AWS::EC2::SecurityGroupIngress.new cfn_model
  ingress_rule.cidrIp = '10.1.2.3/32'
  ingress_rule.ipProtocol = '-1'
  ingress_rule.groupId = ingress_group_id

  expected_security_group = AWS::EC2::SecurityGroup.new cfn_model
  expected_security_group.vpcId = { 'Ref' => 'VpcId' }
  expected_security_group.groupDescription = 'some_group_desc'
  expected_security_group.logical_resource_id = security_group_id
  expected_security_group.ingresses << ingress_rule
  expected_security_group.securityGroupIngress += [{
      'CidrIp' => '10.1.2.3/32',
      'IpProtocol' => '-1'
  }]

  yield expected_security_group, ingress_rule if block_given?
  expected_security_group
end

def standalone_ingress_rule_ip_protocol(cfn_model: CfnModel.new)
  expected_ingress_rule = AWS::EC2::SecurityGroupIngress.new cfn_model
  expected_ingress_rule.cidrIp = '10.1.2.3/32'
  expected_ingress_rule.ipProtocol = '-1'
  expected_ingress_rule.groupId = 'group1'

  expected_ingress_rule
end

def security_group_with_no_rules(cfn_model: CfnModel.new, id: 'sg')
  expected_security_group = AWS::EC2::SecurityGroup.new cfn_model
  expected_security_group.vpcId = { 'Ref' => 'VpcId' }
  expected_security_group.groupDescription = 'some_group_desc'
  expected_security_group.logical_resource_id = id

  yield expected_security_group if block_given?
  expected_security_group
end


def security_group_with_two_ingress_rules(cfn_model: CfnModel.new, id: 'sg2')
  ingress_rule = AWS::EC2::SecurityGroupIngress.new cfn_model
  ingress_rule.cidrIp = '10.1.2.3/32'
  ingress_rule.fromPort = 34
  ingress_rule.toPort = 36
  ingress_rule.ipProtocol = 'tcp'
  ingress_rule.groupId = nil

  ingress_rule2 = AWS::EC2::SecurityGroupIngress.new cfn_model
  ingress_rule2.cidrIp = '10.1.2.4/32'
  ingress_rule2.fromPort = 55
  ingress_rule2.toPort = 56
  ingress_rule2.ipProtocol = 'tcp'
  ingress_rule2.groupId = nil

  expected_security_group = AWS::EC2::SecurityGroup.new cfn_model
  expected_security_group.vpcId = { 'Ref' => 'VpcId' }
  expected_security_group.groupDescription = 'some_group_desc'
  expected_security_group.logical_resource_id = id
  expected_security_group.ingresses << ingress_rule
  expected_security_group.ingresses << ingress_rule2

  yield expected_security_group, ingress_rule, ingress_rule2 if block_given?
  expected_security_group
end

def security_group_with_one_external_egress_rule(cfn_model: CfnModel.new, security_group_id: 'sg1', egress_group_id: nil)
  egress_rule = AWS::EC2::SecurityGroupEgress.new cfn_model
  egress_rule.cidrIp = '5.5.5.5/32'
  egress_rule.fromPort = 39
  egress_rule.toPort = 42
  egress_rule.ipProtocol = 'tcp'
  egress_rule.groupId = egress_group_id

  expected_security_group = AWS::EC2::SecurityGroup.new cfn_model
  expected_security_group.vpcId = { 'Ref' => 'VpcId' }
  expected_security_group.groupDescription = 'some_group_desc'
  expected_security_group.logical_resource_id = security_group_id
  expected_security_group.egresses << egress_rule

  yield expected_security_group, egress_rule if block_given?

  expected_security_group
end

def security_group_with_one_egress_rule(cfn_model: CfnModel.new, security_group_id: 'sg1', egress_group_id: nil)
  raw_egress = {
    'CidrIp' => '5.5.5.5/32',
    'FromPort' => 39,
    'ToPort' => 42,
    'IpProtocol' => 'tcp'
  }

  egress_rule = AWS::EC2::SecurityGroupEgress.new cfn_model
  egress_rule.cidrIp = '5.5.5.5/32'
  egress_rule.fromPort = 39
  egress_rule.toPort = 42
  egress_rule.ipProtocol = 'tcp'
  egress_rule.groupId = egress_group_id

  expected_security_group = AWS::EC2::SecurityGroup.new cfn_model
  expected_security_group.vpcId = { 'Ref' => 'VpcId' }
  expected_security_group.groupDescription = 'some_group_desc'
  expected_security_group.logical_resource_id = security_group_id
  expected_security_group.egresses << egress_rule
  expected_security_group.securityGroupEgress += [raw_egress]

  yield expected_security_group, egress_rule, raw_egress if block_given?

  expected_security_group
end

def security_group_with_one_ingress_and_one_egress_rule(cfn_model: CfnModel.new, id: 'sg2')
  ingress_rule = AWS::EC2::SecurityGroupIngress.new cfn_model
  ingress_rule.cidrIp = '10.1.2.3/32'
  ingress_rule.fromPort = 34
  ingress_rule.toPort = 36
  ingress_rule.ipProtocol = 'tcp'

  egress_rule = AWS::EC2::SecurityGroupEgress.new cfn_model
  egress_rule.cidrIp = '1.2.3.4/32'
  egress_rule.fromPort = 55
  egress_rule.toPort = 56
  egress_rule.ipProtocol = 'tcp'

  expected_security_group = AWS::EC2::SecurityGroup.new cfn_model
  expected_security_group.vpcId = { 'Ref' => 'VpcId' }
  expected_security_group.groupDescription = 'some_group_desc'
  expected_security_group.logical_resource_id = id
  expected_security_group.ingresses << ingress_rule
  expected_security_group.egresses << egress_rule

  expected_security_group.securityGroupIngress +=  [{
    'CidrIp' => '10.1.2.3/32',
    'FromPort' => 34,
    'ToPort' => 36,
    'IpProtocol' => 'tcp'
  }]

  expected_security_group.securityGroupEgress += [{
    'CidrIp' => '1.2.3.4/32',
    'FromPort' => 55,
    'ToPort' => 56,
    'IpProtocol' => 'tcp'
  }]

  yield expected_security_group, ingress_rule, egress_rule if block_given?
  expected_security_group
end

def security_group_with_one_egress_rule_ipprotocol(cfn_model: CfnModel.new, security_group_id: 'sg3', ingress_group_id: nil)
  egress_rule = AWS::EC2::SecurityGroupEgress.new cfn_model
  egress_rule.cidrIp = '10.1.2.3/32'
  egress_rule.ipProtocol = '-1'
  egress_rule.groupId = ingress_group_id

  expected_security_group = AWS::EC2::SecurityGroup.new cfn_model
  expected_security_group.vpcId = { 'Ref' => 'VpcId' }
  expected_security_group.groupDescription = 'some_group_desc'
  expected_security_group.logical_resource_id = security_group_id
  expected_security_group.egresses << egress_rule
  expected_security_group.securityGroupEgress += [{
      'CidrIp' => '10.1.2.3/32',
      'IpProtocol' => '-1'
  }]

  yield expected_security_group, egress_rule if block_given?
  expected_security_group
end

def standalone_egress_rule_ip_protocol(cfn_model: CfnModel.new)
  expected_egress_rule = AWS::EC2::SecurityGroupEgress.new cfn_model
  expected_egress_rule.cidrIp = '10.1.2.3/32'
  expected_egress_rule.ipProtocol = '-1'
  expected_egress_rule.groupId = 'group1'

  expected_egress_rule
end
