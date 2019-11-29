# frozen_string_literal: true

require_relative 'model_element'

class Policy
  attr_accessor :policy_name, :policy_document

  def ==(another_policy)
    policy_name == another_policy.policy_name &&
      policy_document == another_policy.policy_document
  end
end
