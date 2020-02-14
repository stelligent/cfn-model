# frozen_string_literal: true

# Compute the role_id for parsed Lambda function
class LambdaFunctionParser
  def parse(cfn_model:, resource:)
    lambda_function = resource

    lambda_function.role_object = cfn_model.resource_by_ref(lambda_function.role, 'Arn')

    lambda_function
  end
end
