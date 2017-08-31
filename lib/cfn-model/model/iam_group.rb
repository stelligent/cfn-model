require_relative 'model_element'

class AWS::IAM::Group  < ModelElement
  attr_accessor :groupName, :managedPolicyArns, :path, :policies

  # synthesized version of policies
  attr_accessor :policy_objects

  def initialize
    @managedPolicyArns = []
    @policies = []
    @policy_objects = []
    @resource_type = 'AWS::IAM::Group'
  end
end