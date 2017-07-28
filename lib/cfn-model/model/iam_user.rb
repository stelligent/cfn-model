require_relative 'model_element'

class AWS::IAM::User  < ModelElement
  attr_accessor :groups, :loginProfile, :path, :policies, :userName

  # synthesized version of policies
  attr_accessor :policy_objects, :group_names

  def initialize
    @groups = []
    @policies = []
    @policy_objects = []
    @group_names = []
    @resource_type = 'AWS::IAM::User'
  end
end
