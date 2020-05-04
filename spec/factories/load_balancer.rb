def load_balancer_with_open_http_ingress(cfn_model: CfnModel.new)
  ingress_rule = AWS::EC2::SecurityGroupIngress.new cfn_model
  ingress_rule.cidrIp = '0.0.0.0/0'
  ingress_rule.fromPort = 80
  ingress_rule.toPort = 80
  ingress_rule.ipProtocol = 'tcp'

  expected_security_group = AWS::EC2::SecurityGroup.new cfn_model
  expected_security_group.groupDescription = 'some_group_desc'
  expected_security_group.ingresses << ingress_rule
  expected_security_group.securityGroupIngress += [{
    'CidrIp' => '0.0.0.0/0',
    'FromPort' => 80,
    'ToPort' => 80,
    'IpProtocol' => 'tcp'
  }]
  expected_security_group.vpcId = {
    'Ref' => 'VpcId'
  }

  expected_load_balancer = AWS::ElasticLoadBalancing::LoadBalancer.new cfn_model
  expected_load_balancer.listeners = [
    {
      'LoadBalancerPort' => '80',
      'InstancePort' => '80',
      'Protocol' => 'HTTP'
    }
  ]
  expected_load_balancer.securityGroups += [{
    'Ref' => 'httpSg'
  }]
  expected_load_balancer.security_groups << expected_security_group
  expected_load_balancer.subnets = [
    {
      'Ref' => 'SubnetId'
    }
  ]
  expected_load_balancer
end

def load_balancer_with_open_http_ingress_and_comma_delimited_sg(cfn_model: CfnModel.new)
  expected_load_balancer = AWS::ElasticLoadBalancing::LoadBalancer.new cfn_model
  expected_load_balancer.listeners = [
    {
      'LoadBalancerPort' => '80',
      'InstancePort' => '80',
      'Protocol' => 'HTTP'
    }
  ]
  expected_load_balancer.securityGroups = {
    'Ref' => 'sgCommaDelimitedList'
  }
  expected_load_balancer.subnets = [
    {
      'Ref' => 'SubnetId'
    }
  ]
  expected_load_balancer
end

def load_balancer2_with_open_http_ingress(cfn_model: CfnModel.new)
  ingress_rule = AWS::EC2::SecurityGroupIngress.new cfn_model
  ingress_rule.cidrIp = '0.0.0.0/0'
  ingress_rule.fromPort = 80
  ingress_rule.toPort = 80
  ingress_rule.ipProtocol = 'tcp'

  expected_security_group = AWS::EC2::SecurityGroup.new cfn_model
  expected_security_group.groupDescription = 'some_group_desc'
  expected_security_group.ingresses << ingress_rule
  expected_security_group.securityGroupIngress += [{
    'CidrIp' => '0.0.0.0/0',
    'FromPort' => 80,
    'ToPort' => 80,
    'IpProtocol' => 'tcp'
  }]
  expected_security_group.vpcId = {
    'Ref' => 'VpcId'
  }

  expected_load_balancer = AWS::ElasticLoadBalancingV2::LoadBalancer.new cfn_model
  expected_load_balancer.scheme = 'internal'
  expected_load_balancer.securityGroups += [{
    'Ref' => 'httpSg'
  }]
  expected_load_balancer.security_groups << expected_security_group
  expected_load_balancer.loadBalancerAttributes += [{
    'Key' => 'idle_timeout.timeout_seconds',
    'Value' => '50'
  }]
  expected_load_balancer.subnets = [
    {
      'Ref' => 'SubnetId1'
    },
    {
      'Ref' => 'SubnetId2'
    }
  ]
  expected_load_balancer
end


def network_load_balancer(cfn_model: CfnModel.new)
  expected_load_balancer = AWS::ElasticLoadBalancingV2::LoadBalancer.new cfn_model
  expected_load_balancer.scheme = 'internet-facing'
  expected_load_balancer.type = 'network'
  expected_load_balancer.subnetMappings = [
    {
      'AllocationId' => { 'Fn::GetAtt' => ['FirstEIP','AllocationId']},
      'SubnetId' => {'Ref'=>'SubnetId1'}
    },
    {
      'AllocationId' => { 'Fn::GetAtt' => ['SecondEIP','AllocationId']},
      'SubnetId' => {'Ref'=>'SubnetId2'}
    }
  ]
  expected_load_balancer
end
