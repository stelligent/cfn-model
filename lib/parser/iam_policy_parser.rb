require 'model/iam_policy'
require 'model/policy_document'

class IamPolicyParser
  def parse(cfn_model:, resource:)
    iam_policy = resource

    iam_policy.policyDocument = PolicyDocumentParser.new.parse(iam_policy.policyDocument)
    iam_policy
  end
end
