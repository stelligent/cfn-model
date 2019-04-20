# frozen_string_literal: true

require_relative 'model_element'

class Policy
  attr_accessor :policy_name, :policy_document

  def ==(other)
    policy_name == other.policy_name &&
      policy_document == other.policy_document
  end
end
