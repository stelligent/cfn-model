# frozen_string_literal: true

require_relative 'model_element'

class AWS::SQS::QueuePolicy < ModelElement
  # PolicyDocument - objectified policyDocument
  attr_accessor :policy_document

  def initialize(cfn_model)
    super
    @queues = []
    @resource_type = 'AWS::SQS::QueuePolicy'
  end
end
