# frozen_string_literal: true

require_relative 'model_element'

class AWS::ApiGateway::Deployment  < ModelElement
  attr_accessor :usage_plan_ids

  def initialize(cfn_model)
    super
    @usage_plan_ids = []
    @resource_type = 'AWS::ApiGateway::Deployment'
  end
end