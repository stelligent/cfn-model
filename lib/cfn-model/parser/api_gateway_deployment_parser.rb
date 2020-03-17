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

  def attached_usage_plans(cfn_model)
    usage_plans = cfn_model.resources_by_type 'AWS::ApiGateway::UsagePlan'
    usage_plans.select { |usage_plan| !usage_plan.apiStages.nil? }
  end

  def stages_for_deployment(cfn_model, deployment)
    stages = cfn_model.resources_by_type 'AWS::ApiGateway::Stage'
    stages.select { |stage| stage.deploymentId ? References.resolve_resource_id(stage.deploymentId) == deployment.logical_resource_id : false }
  end

  def deployment_creates_stage?(deployment)
    !deployment.stageName.nil?
  end

  def usage_plans_for_stage_by_resource_id(cfn_model, logical_resource_id)
    usage_plans = attached_usage_plans(cfn_model)
    usage_plans.select do |usage_plan|
      stages = usage_plan.apiStages.select do |up_api_stage|
        References.resolve_resource_id(up_api_stage['Stage']) == logical_resource_id
      end
      !stages.empty?
    end
  end

  def usage_plans_for_stage_by_stage_name(cfn_model, stage_name)
    usage_plans = attached_usage_plans(cfn_model)
    usage_plans.select do |usage_plan|
      stages = usage_plan.apiStages.select do |up_api_stage|
        up_api_stage['Stage'] == stage_name
      end
      !stages.empty?
    end
  end

  def attach_usage_plans_for_deployment_that_creates_stage(cfn_model, deployment)
    usage_plans_for_stage_by_stage_name(cfn_model, deployment.stageName).each do |usage_plan|
      deployment.usage_plan_ids << usage_plan.logical_resource_id
    end
  end

  def attach_usage_plans_for_deployment_without_stage_name(cfn_model, deployment)
    stages_for_deployment(cfn_model, deployment).each do |stage|
      usage_plans_for_stage_by_resource_id(cfn_model, stage.logical_resource_id).each do |usage_plan|
        deployment.usage_plan_ids << usage_plan.logical_resource_id
      end
    end
  end

  def attach_usage_plan_to_api_deployment(cfn_model:, deployment:)
    if deployment_creates_stage?(deployment)
      attach_usage_plans_for_deployment_that_creates_stage(cfn_model, deployment)
    else
      attach_usage_plans_for_deployment_without_stage_name(cfn_model, deployment)
    end
  end
end
