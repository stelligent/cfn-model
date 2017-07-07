require_relative 'model_element'

class AWS::IAM::Group  < ModelElement
  attr_accessor :groupName, :managedPolicyArns, :path, :policies

  def initialize
    @managedPolicyArns = []
    @policies = []
    @resource_type = 'AWS::IAM::Group'
  end
end


class AWS::IAM::UserToGroupAddition  < ModelElement
  attr_accessor :groupName, :users

  def initialize
    @users = []
    @resource_type = 'AWS::IAM::UserToGroupAddition'
  end
end