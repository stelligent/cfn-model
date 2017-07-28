require_relative 'model_element'

class AWS::IAM::Role < ModelElement
  attr_accessor :roleName, :assumeRolePolicyDocument, :policies, :path, :managedPolicyArns

  attr_accessor :policy_objects, :assume_role_policy_document

  def initialize
    @policies = []
    @managedPolicyArns = []
    @policy_objects = []
    @resource_type = 'AWS::IAM::Role'
  end
end
