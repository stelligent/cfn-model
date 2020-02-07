# frozen_string_literal: true

require 'cfn-model/model/lambda_function'
require 'cfn-model/model/references'

# Compute the role_id for parsed Lambda function
class LambdaFunctionParser
  def parse(cfn_model:, resource:)
    lambda_function = resource

    wire_role_to_lambda_function(cfn_model, lambda_function)

    lambda_function
  end

  private

  def wire_role_to_lambda_function(cfn_model, lambda_function)
    if lambda_function.role.instance_of?(String)
      lambda_function.role_object = nil
      return
    end

    role_id = References.resolve_resource_id(lambda_function.role)

    roles = cfn_model.resources_by_type 'AWS::IAM::Role'
    roles.each do |role|
      if role.logical_resource_id == role_id
        lambda_function.role_object = role
      end
    end
  end

  def role_id(cfn_model, role_reference)
    References.resolve_value(cfn_model, role_reference)
  end
end
