require_relative 'model_element'

class AWS::ElasticLoadBalancing::LoadBalancer < ModelElement
  attr_accessor :securityGroups, :subnets, :tags, :scheme, :loadBalancerName, :crossZone, :availabilityZones, :connectionDrainingPolicy
  attr_accessor :connectionSettings, :accessLoggingPolicy, :instances, :appCookieStickinessPolicy, :lBCookieStickinessPolicy, :healthCheck, :policies, :listeners

  attr_accessor :security_groups

  def initialize
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
  attr_accessor :securityGroups, :loadBalancerAttributes, :subnets, :tags, :scheme, :name, :ipAddressType

  attr_accessor :security_groups

  def initialize
    @securityGroups = []
    @security_groups = []
    @loadBalancerAttributes = []
    @subnets = []
    @tags = []
    @resource_type = 'AWS::ElasticLoadBalancingV2::LoadBalancer'
  end
end