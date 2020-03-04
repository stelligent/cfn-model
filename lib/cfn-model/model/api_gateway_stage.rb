# frozen_string_literal: true

require_relative 'model_element'

class AWS::ApiGateway::Stage  < ModelElement
  attr_accessor :usage_plan, :deployment_id

  def initialize(cfn_model)
    super
    @usage_plan = []
    @deployment_id = []
    @resource_type = 'AWS::ApiGateway::Stage'
  end
end