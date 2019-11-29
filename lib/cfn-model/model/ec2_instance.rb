# frozen_string_literal: true

require_relative 'model_element'

class AWS::EC2::Instance  < ModelElement
  # SecurityGroup objects based upon securityGroupIds
  attr_accessor :security_groups

  def initialize(cfn_model)
    super
    @securityGroupIds = []
    @networkInterfaces = []
    @security_groups = []
    @resource_type = 'AWS::EC2::Instance'
  end
end
