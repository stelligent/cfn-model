def load_balancer_with_open_http_ingress
  ingress_rule = AWS::EC2::SecurityGroupIngress.new
  ingress_rule.cidrIp = '0.0.0.0/0'
  ingress_rule.fromPort = 80
  ingress_rule.toPort = 80
  ingress_rule.ipProtocol = 'tcp'

  expected_security_group = AWS::EC2::SecurityGroup.new
  expected_security_group.groupDescription = 'some_group_desc'
  expected_security_group.ingresses << ingress_rule
  expected_security_group.securityGroupIngress << {
    'CidrIp' => '0.0.0.0/0',
    'FromPort' => 80,
    'ToPort' => 80,
    'IpProtocol' => 'tcp'
  }
  expected_security_group.vpcId = {
    'Ref' => 'VpcId'
  }

  expected_load_balancer = AWS::ElasticLoadBalancing::LoadBalancer.new
  expected_load_balancer.listeners = [
    {
      'LoadBalancerPort' => '80',
      'InstancePort' => '80',
      'Protocol' => 'HTTP'
    }
  ]
  expected_load_balancer.securityGroups << {
    'Ref' => 'httpSg'
  }
  expected_load_balancer.security_groups << expected_security_group
  expected_load_balancer.subnets = [
    {
      'Ref' => 'SubnetId'
    }
  ]
  expected_load_balancer
end

def load_balancer2_with_open_http_ingress
  ingress_rule = AWS::EC2::SecurityGroupIngress.new
  ingress_rule.cidrIp = '0.0.0.0/0'
  ingress_rule.fromPort = 80
  ingress_rule.toPort = 80
  ingress_rule.ipProtocol = 'tcp'

  expected_security_group = AWS::EC2::SecurityGroup.new
  expected_security_group.groupDescription = 'some_group_desc'
  expected_security_group.ingresses << ingress_rule
  expected_security_group.securityGroupIngress << {
    'CidrIp' => '0.0.0.0/0',
    'FromPort' => 80,
    'ToPort' => 80,
    'IpProtocol' => 'tcp'
  }
  expected_security_group.vpcId = {
    'Ref' => 'VpcId'
  }

  expected_load_balancer = AWS::ElasticLoadBalancingV2::LoadBalancer.new
  expected_load_balancer.scheme = 'internal'
  expected_load_balancer.securityGroups << {
    'Ref' => 'httpSg'
  }
  expected_load_balancer.security_groups << expected_security_group
  expected_load_balancer.loadBalancerAttributes << {
    'Key' => 'idle_timeout.timeout_seconds',
    'Value' => '50'
  }
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
