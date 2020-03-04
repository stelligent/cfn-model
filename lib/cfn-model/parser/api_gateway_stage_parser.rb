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
        if up_api_stage['Stage'].is_a?(Hash) && up_api_stage['Stage'].key?('Ref')
          if api_stage.logical_resource_id == up_api_stage['Stage']['Ref']
            api_stage.usage_plan << usage_plan.logical_resource_id
          end
        end
      end
    end
  end

  def attach_deployment_id_to_api_stage(cfn_model:, api_stage:)
    api_deployments = cfn_model.resources_by_type 'AWS::ApiGateway::Deployment'
    api_deployments.each do |deployment|
      if api_stage.deploymentId.is_a?(Hash) && api_stage.deploymentId.key?('Ref')
        if deployment.logical_resource_id == api_stage.deploymentId['Ref']
          api_stage.deployment_id << deployment.logical_resource_id
        end
      end
    end
  end
end