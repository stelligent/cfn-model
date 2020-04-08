# frozen_string_literal: true

require_relative 'model_element'

class AWS::EC2::NetworkAclEntry < ModelElement
  def initialize(cfn_model)
    super
    @resource_type = 'AWS::EC2::NetworkAclEntry'
  end
end
