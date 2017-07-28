require_relative 'model_element'

class AWS::EC2::Instance  < ModelElement
  attr_accessor :securityGroupIds, :networkInterfaces

  # SecurityGroup objects based upon securityGroupIds
  attr_accessor :security_groups

  def initialize
    @securityGroupIds = []
    @networkInterfaces = []
    @security_groups = []
    @resource_type = 'AWS::EC2::Instance'
  end
end
