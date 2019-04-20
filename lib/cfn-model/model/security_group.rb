# frozen_string_literal: true

require_relative 'model_element'

class AWS::EC2::SecurityGroup < ModelElement
  attr_accessor :ingresses, :egresses

  def initialize(cfn_model)
    super
    @securityGroupIngress = []
    @securityGroupEgress = []
    @ingresses = []
    @egresses = []
    @tags = []
    @resource_type = 'AWS::EC2::SecurityGroup'
  end
end
