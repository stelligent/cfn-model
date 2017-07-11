require 'cfn-model/model/iam_policy'
require 'cfn-model/model/policy_document'
require_relative 'policy_document_parser'

class WithPolicyDocumentParser
  def parse(cfn_model:, resource:)
    resource.policyDocument = PolicyDocumentParser.new.parse(resource.policyDocument)
    resource
  end
end
