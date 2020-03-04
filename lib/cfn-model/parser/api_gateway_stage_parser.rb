# frozen_string_literal: true

require_relative 'parser_error'
require 'cfn-model/model/api_gateway_stage'
require 'cfn-model/model/references'

class ApiGatewayStageParser

  def parse(cfn_model:, resource:)
    api_stage = resource

    attach_usage_plan_to_api_stage(cfn_model: cfn_model, api_stage: api_stage)
    attach_deployment_id_to_api_stage(cfn_model: cfn_model, api_stage: api_stage)
    api_stage
  end

  private

  def attach_usage_plan_to_api_stage(cfn_model:, api_stage:)
    usage_plans = cfn_model.resources_by_type 'AWS::ApiGateway::UsagePlan'
    usage_plans.each do |usage_plan|
      next if usage_plan.apiStages.nil?
      usage_plan.apiStages.each do |up_api_stage|
        if References.resolve_resource_id(up_api_stage['Stage']) == api_stage.logical_resource_id
            api_stage.usage_plan_ids << usage_plan.logical_resource_id
        end
      end
    end
  end

  def attach_deployment_id_to_api_stage(cfn_model:, api_stage:)
    api_deployments = cfn_model.resources_by_type 'AWS::ApiGateway::Deployment'
    api_deployments.each do |deployment|
      next if api_stage.deploymentId.nil?
      if References.resolve_resource_id(api_stage.deploymentId) == deployment.logical_resource_id
        api_stage.deployment = deployment.logical_resource_id
      end
    end
  end
end