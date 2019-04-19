# frozen_string_literal: true

require_relative 'model_element'

class AWS::SNS::TopicPolicy < ModelElement
  # PolicyDocument - objectified policyDocument
  attr_accessor :policy_document

  def initialize(cfn_model)
    super
    @topics = []
    @resource_type = 'AWS::SNS::TopicPolicy'
  end
end
