require_relative 'model_element'

class AWS::EC2::NetworkInterface  < ModelElement
  attr_accessor :groupSet, :ipv6Addresses, :privateIpAddresses, :tags
  attr_accessor :description, :ipv6AddressCount, :privateIpAddress, :secondaryPrivateIpAddressCount, :sourceDestCheck, :subnetId

  # SecurityGroup objects based upon groupSet
  attr_accessor :security_groups

  def initialize
    @groupSet = []
    @ipv6Addresses = []
    @privateIpAddresses = []
    @tags = []
    @security_groups = []
    @resource_type = 'AWS::EC2::NetworkInterface'
  end
end
