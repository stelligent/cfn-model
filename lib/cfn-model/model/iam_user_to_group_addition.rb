require_relative 'model_element'

class AWS::IAM::UserToGroupAddition  < ModelElement
  attr_accessor :groupName, :users

  def initialize
    @users = []
    @resource_type = 'AWS::IAM::UserToGroupAddition'
  end
end