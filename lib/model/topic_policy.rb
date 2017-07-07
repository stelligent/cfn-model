require_relative 'model_element'

class AWS::SNS::TopicPolicy  < ModelElement
  attr_accessor :topics, :policyDocument

  def initialize
    @topics = []
    @resource_type = 'AWS::SNS::TopicPolicy'
  end
end
