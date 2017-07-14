require_relative 'model_element'

class AWS::IAM::ManagedPolicy < ModelElement
  attr_accessor :description, :managedPolicyName, :policyDocument, :groups, :roles, :users, :path

  def initialize
    @groups = []
    @roles = []
    @users = []
    @resource_type = 'AWS::IAM::ManagedPolicy'
  end
end
