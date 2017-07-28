require 'cfn-model/model/iam_role'
require 'cfn-model/model/policy'
require_relative 'policy_document_parser'

class IamGroupParser
  def parse(cfn_model:, resource:)
    iam_group = resource

    iam_group.policy_objects = iam_group.policies.map do |policy|
      new_policy = Policy.new
      new_policy.policyName = policy['PolicyName']
      new_policy.policyDocument = PolicyDocumentParser.new.parse(policy['PolicyDocument'])
      new_policy
    end
    iam_group
  end
end
