# frozen_string_literal: true

require_relative 'parser_error'
require 'cfn-model/model/api_gateway_deployment'
require 'cfn-model/model/references'

class ApiGatewayDeploymentParser

  def parse(cfn_model:, resource:)
    deployment = resource

    attach_usage_plan_to_api_deployment(cfn_model: cfn_model, deployment: deployment)
    deployment
  end

  private

  def attach_usage_plan_to_api_deployment(cfn_model:, deployment:)
    api_stages = cfn_model.resources_by_type 'AWS::ApiGateway::Stage'
    usage_plans = cfn_model.resources_by_type 'AWS::ApiGateway::UsagePlan'
    usage_plans.each do |usage_plan|
      next if usage_plan.apiStages.nil?
      usage_plan.apiStages.each do |up_api_stage|
        if deployment.stageName.nil?
          api_stages.each do |stage|
            if References.resolve_resource_id(stage.deploymentId) == deployment.logical_resource_id
              if References.resolve_resource_id(up_api_stage['Stage']) == stage.logical_resource_id
                deployment.usage_plan_ids << usage_plan.logical_resource_id
              end
            end
          end
        else
          if up_api_stage['Stage'] == deployment.stageName
            deployment.usage_plan_ids << usage_plan.logical_resource_id
          end
        end
      end
    end
  end
end
