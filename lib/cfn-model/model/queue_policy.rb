require_relative 'model_element'

class AWS::SQS::QueuePolicy  < ModelElement
  attr_accessor :queues, :policyDocument

  def initialize
    @queues = []
    @resource_type = 'AWS::SQS::QueuePolicy'
  end
end
