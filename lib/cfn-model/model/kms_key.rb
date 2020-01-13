# frozen_string_literal: true

require_relative 'model_element'

class AWS::KMS::Key < ModelElement
  attr_accessor :key_policy

  def initialize(cfn_model)
    super
    @key_policy = nil
    @resource_type = 'AWS::KMS::Key'
  end
end
