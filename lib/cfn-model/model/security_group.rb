require_relative 'model_element'

class AWS::EC2::SecurityGroup < ModelElement
  attr_accessor :groupDescription, :vpcId
  attr_accessor :tags
  attr_accessor :securityGroupIngress, :securityGroupEgress

  def initialize
    @securityGroupIngress = []
    @securityGroupEgress = []
    @tags = []
    @resource_type = 'AWS::EC2::SecurityGroup'
  end
end