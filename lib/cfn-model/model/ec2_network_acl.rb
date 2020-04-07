# frozen_string_literal: true

require_relative 'model_element'

class AWS::EC2::NetworkAcl < ModelElement
  attr_accessor :network_acl_entries

  def initialize(cfn_model)
    super
    @network_acl_entries = []
    @resource_type = 'AWS::EC2::NetworkAcl'
  end
end
