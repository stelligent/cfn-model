# frozen_string_literal: true

require_relative 'model_element'

class AWS::ApiGateway::Stage  < ModelElement
  attr_accessor :usage_plan_ids, :deployment

  def initialize(cfn_model)
    super
    @usage_plan_ids = []
    @deployment = nil
    @resource_type = 'AWS::ApiGateway::Stage'
  end
end