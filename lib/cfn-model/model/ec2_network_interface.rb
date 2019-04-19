# frozen_string_literal: true

require_relative 'model_element'

class AWS::EC2::NetworkInterface < ModelElement
  # SecurityGroup objects based upon groupSet
  attr_accessor :security_groups

  def initialize(cfn_model)
    super
    @groupSet = []
    @ipv6Addresses = []
    @privateIpAddresses = []
    @tags = []
    @security_groups = []
    @resource_type = 'AWS::EC2::NetworkInterface'
  end
end
