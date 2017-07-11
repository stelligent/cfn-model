require 'cfn-model/model/iam_role'
require 'cfn-model/model/policy_document'
require_relative 'policy_document_parser'

class IamRoleParser
  def parse(cfn_model:, resource:)
    iam_role = resource

    iam_role.assumeRolePolicyDocument = PolicyDocumentParser.new.parse(iam_role.assumeRolePolicyDocument)

    iam_role.policies = iam_role.policies.map do |policy|

      new_policy = Policy.new
      new_policy.policyName = policy['PolicyName']
      new_policy.policyDocument = PolicyDocumentParser.new.parse(policy['PolicyDocument'])
      new_policy
    end
    iam_role
  end
end
