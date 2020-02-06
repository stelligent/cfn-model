# frozen_string_literal: true

require 'cfn-model/model/lambda_function'

# Compute the role_id for parsed Lambda function
class LambdaFunctionParser
  def parse(cfn_model:, resource:)
    lambda_function = resource

    if lambda_function.role.instance_of?(String)
      lambda_function.role_id = lambda_function.role
    else
      role_value = lambda_function.role.values[0]
      lambda_function.role_id = \
        role_value.instance_of?(String) ? role_value.split('.')[0] : role_value[0]
    end

    lambda_function
  end
end
