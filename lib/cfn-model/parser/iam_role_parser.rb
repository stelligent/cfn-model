# frozen_string_literal: true

require 'cfn-model/model/iam_role'
require 'cfn-model/model/policy'
require 'cfn-model/model/references'
require_relative 'policy_document_parser'

class IamRoleParser
  def parse(cfn_model:, resource:)
    iam_role = resource

    iam_role.assume_role_policy_document = PolicyDocumentParser.new.parse(cfn_model, iam_role.assumeRolePolicyDocument)

    iam_role.policy_objects = iam_role.policies.map do |policy|
      next unless policy.has_key? 'PolicyName'

      new_policy = Policy.new
      new_policy.policy_name = References.resolve_value(cfn_model, policy['PolicyName'])
      new_policy.policy_document = PolicyDocumentParser.new.parse(cfn_model, policy['PolicyDocument'])
      new_policy
    end.reject { |policy| policy.nil? }

    iam_role
  end
end
