# frozen_string_literal: true

require_relative 'model_element'

class AWS::EC2::NetworkAcl < ModelElement
  attr_accessor :network_acl_egress_entries
  attr_accessor :network_acl_ingress_entries

  def initialize(cfn_model)
    super
    @network_acl_egress_entries = []
    @network_acl_ingress_entries = []
    @resource_type = 'AWS::EC2::NetworkAcl'
  end
end