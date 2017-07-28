require_relative 'model_element'

class AWS::SQS::QueuePolicy  < ModelElement
  attr_accessor :queues, :policyDocument

  # PolicyDocument - objectified policyDocument
  attr_accessor :policy_document

  def initialize
    @queues = []
    @resource_type = 'AWS::SQS::QueuePolicy'
  end
end
