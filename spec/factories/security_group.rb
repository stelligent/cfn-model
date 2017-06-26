require 'model/security_group'
require 'model/security_group_ingress'

def security_group_with_one_ingress_rule(security_group_id: 'sg2', ingress_group_id: nil)
  ingress_rule = SecurityGroupIngress.new
  ingress_rule.cidrIp = '10.1.2.3/32'
  ingress_rule.fromPort = 34
  ingress_rule.toPort = 36
  ingress_rule.ipProtocol = 'tcp'
  ingress_rule.groupId = ingress_group_id

  expected_security_group = SecurityGroup.new
  expected_security_group.vpcId = { 'Ref' => 'VpcId' }
  expected_security_group.groupDescription = 'some_group_desc'
  expected_security_group.logical_resource_id = security_group_id
  expected_security_group.add_ingress_rule ingress_rule

  yield expected_security_group, ingress_rule if block_given?
  expected_security_group
end

def security_group_with_no_rules(id: 'sg')
  expected_security_group = SecurityGroup.new
  expected_security_group.vpcId = { 'Ref' => 'VpcId' }
  expected_security_group.groupDescription = 'some_group_desc'
  expected_security_group.logical_resource_id = id

  yield expected_security_group if block_given?
  expected_security_group
end


def security_group_with_two_ingress_rules(id: 'sg2')
  ingress_rule = SecurityGroupIngress.new
  ingress_rule.cidrIp = '10.1.2.3/32'
  ingress_rule.fromPort = 34
  ingress_rule.toPort = 36
  ingress_rule.ipProtocol = 'tcp'
  ingress_rule.groupId = nil

  ingress_rule2 = SecurityGroupIngress.new
  ingress_rule2.cidrIp = '10.1.2.4/32'
  ingress_rule2.fromPort = 55
  ingress_rule2.toPort = 56
  ingress_rule2.ipProtocol = 'tcp'
  ingress_rule2.groupId = nil

  expected_security_group = SecurityGroup.new
  expected_security_group.vpcId = { 'Ref' => 'VpcId' }
  expected_security_group.groupDescription = 'some_group_desc'
  expected_security_group.logical_resource_id = id
  expected_security_group.add_ingress_rule ingress_rule
  expected_security_group.add_ingress_rule ingress_rule2

  yield expected_security_group, ingress_rule, ingress_rule2 if block_given?
  expected_security_group
end

def security_group_with_one_egress_rule(security_group_id: 'sg1', egress_group_id: nil)
  egress_rule = SecurityGroupEgress.new
  egress_rule.cidrIp = '5.5.5.5/32'
  egress_rule.fromPort = 39
  egress_rule.toPort = 42
  egress_rule.ipProtocol = 'tcp'
  egress_rule.groupId = egress_group_id

  expected_security_group = SecurityGroup.new
  expected_security_group.vpcId = { 'Ref' => 'VpcId' }
  expected_security_group.groupDescription = 'some_group_desc'
  expected_security_group.logical_resource_id = security_group_id
  expected_security_group.add_egress_rule egress_rule

  yield expected_security_group, egress_rule if block_given?

  expected_security_group
end

def security_group_with_one_ingress_and_one_egress_rule(id: 'sg2')
  ingress_rule = SecurityGroupIngress.new
  ingress_rule.cidrIp = '10.1.2.3/32'
  ingress_rule.fromPort = 34
  ingress_rule.toPort = 36
  ingress_rule.ipProtocol = 'tcp'
  ingress_rule.groupId = nil

  egress_rule = SecurityGroupEgress.new
  egress_rule.cidrIp = '1.2.3.4/32'
  egress_rule.fromPort = 55
  egress_rule.toPort = 56
  egress_rule.ipProtocol = 'tcp'
  egress_rule.groupId = nil

  expected_security_group = SecurityGroup.new
  expected_security_group.vpcId = { 'Ref' => 'VpcId' }
  expected_security_group.groupDescription = 'some_group_desc'
  expected_security_group.logical_resource_id = id
  expected_security_group.add_ingress_rule ingress_rule
  expected_security_group.add_egress_rule egress_rule

  yield expected_security_group, ingress_rule, egress_rule if block_given?
  expected_security_group
end
