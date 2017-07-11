require_relative 'model_element'

class AWS::IAM::Role  < ModelElement
  attr_accessor :roleName, :assumeRolePolicyDocument, :policies, :path, :managedPolicyArns

  def initialize
    @policies = []
    @managedPolicyArns = []
    @resource_type = 'AWS::IAM::Role'
  end
end

class Policy
  attr_accessor :policyName, :policyDocument

  def ==(another_policy)
    policyName == another_policy.policyName &&
      policyDocument == another_policy.policyDocument
  end
end
