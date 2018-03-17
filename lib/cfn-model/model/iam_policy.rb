require_relative 'model_element'

class AWS::IAM::Policy < ModelElement
  attr_accessor :policyName, :policyDocument, :groups, :roles, :users

  attr_accessor :policy_document

  def initialize(cfn_model)
    super
    @groups = []
    @roles = []
    @users = []
    @resource_type = 'AWS::IAM::Policy'
  end
end
