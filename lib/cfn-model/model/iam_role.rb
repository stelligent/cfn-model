require_relative 'model_element'

class AWS::IAM::Role < ModelElement
  attr_accessor :policy_objects, :assume_role_policy_document

  def initialize(cfn_model)
    super
    @policies = []
    @managedPolicyArns = []
    @policy_objects = []
    @resource_type = 'AWS::IAM::Role'
  end
end
