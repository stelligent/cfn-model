# frozen_string_literal: true

require_relative 'model_element'

# Explicitly creating this element in order
# to compute the role ID if not a string
class AWS::Lambda::Function < ModelElement
  attr_accessor :role_id

  def initialize(cfn_model)
    super
    @role_id = nil
    @resource_type = 'AWS::Lambda::Function'
  end
end
