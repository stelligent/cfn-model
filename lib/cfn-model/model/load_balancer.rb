# frozen_string_literal: true

require_relative 'model_element'

class AWS::ElasticLoadBalancing::LoadBalancer < ModelElement
  attr_accessor :security_groups

  def initialize(cfn_model)
    super
    @securityGroups = []
    @security_groups = []
    @subnets = []
    @tags = []
    @availabilityZones = []
    @instances = []
    @appCookieStickinessPolicy = []
    @lBCookieStickinessPolicy = []
    @policies = []
    @listeners = []
    @resource_type = 'AWS::ElasticLoadBalancing::LoadBalancer'
  end
end

class AWS::ElasticLoadBalancingV2::LoadBalancer < ModelElement
  attr_accessor :security_groups

  def initialize(cfn_model)
    super
    @securityGroups = []
    @security_groups = []
    @loadBalancerAttributes = []
    @subnets = []
    @tags = []
    @resource_type = 'AWS::ElasticLoadBalancingV2::LoadBalancer'
  end
end
