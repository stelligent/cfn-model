# frozen_string_literal: true

require 'cfn-model/model/iam_role'
require 'cfn-model/model/policy'
require_relative 'policy_document_parser'

class IamRoleParser
  def parse(cfn_model:, resource:)
    iam_role = resource

    iam_role.assume_role_policy_document = PolicyDocumentParser.new.parse(iam_role.assumeRolePolicyDocument)

    iam_role.policy_objects = iam_role.policies.map do |policy|
      next unless policy.key? 'PolicyName'

      new_policy = Policy.new
      new_policy.policy_name = policy['PolicyName']
      new_policy.policy_document = PolicyDocumentParser.new.parse(policy['PolicyDocument'])
      new_policy
    end.reject { |policy| policy.nil? }

    iam_role
  end
end
