require_relative 'model_element'

class AWS::IAM::Role  < ModelElement
  attr_accessor :roleName, :assumeRolePolicyDocument, :policies, :path, :managedPolicyArns

  def initialize
    @policies = []
    @managedPolicyArns = []
    @resource_type = 'AWS::IAM::Role'
  end
end
