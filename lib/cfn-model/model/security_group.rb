require_relative 'model_element'

class AWS::EC2::SecurityGroup < ModelElement
  attr_accessor :groupDescription, :vpcId
  attr_accessor :tags
  attr_accessor :securityGroupIngress, :securityGroupEgress

  attr_accessor :ingresses, :egresses

  def initialize
    @securityGroupIngress = []
    @securityGroupEgress = []
    @ingresses = []
    @egresses = []
    @tags = []
    @resource_type = 'AWS::EC2::SecurityGroup'
  end
end