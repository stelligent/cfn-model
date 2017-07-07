require_relative 'model_element'

class AWS::EC2::SecurityGroup < ModelElement
  attr_accessor :groupDescription, :vpcId
  attr_accessor :securityGroupIngress, :securityGroupEgress

  def initialize
    @securityGroupIngress = []
    @securityGroupEgress = []
    @resource_type = 'AWS::EC2::SecurityGroup'
  end

  def valid?(resource_name)
    # hmmm nothing to do here beyond the required structure already proven
    true
  end
end