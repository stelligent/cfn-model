require_relative 'model_element'

class AWS::IAM::Policy < ModelElement
  attr_accessor :policyName, :policyDocument, :groups, :roles, :users

  def initialize
    @groups = []
    @roles = []
    @users = []
    @resource_type = 'AWS::IAM::Policy'
  end
end
