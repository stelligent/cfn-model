require_relative 'model_element'

class AWS::SNS::TopicPolicy < ModelElement
  attr_accessor :topics, :policyDocument

  # PolicyDocument - objectified policyDocument
  attr_accessor :policy_document

  def initialize(cfn_model)
    super
    @topics = []
    @resource_type = 'AWS::SNS::TopicPolicy'
  end
end
