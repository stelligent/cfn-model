# frozen_string_literal: true

require 'cfn-model/model/kms_key'
require 'cfn-model/model/policy'
require_relative 'policy_document_parser'

class KmsKeyParser
  def parse(cfn_model:, resource:)
    kms_key = resource

    new_policy = Policy.new
    new_policy.policy_document = PolicyDocumentParser.new.parse(cfn_model, kms_key.keyPolicy)
    kms_key.key_policy = new_policy

    kms_key
  end
end
