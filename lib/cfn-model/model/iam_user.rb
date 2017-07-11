require_relative 'model_element'

class AWS::IAM::User  < ModelElement
  attr_accessor :groups, :loginProfile, :path, :policies, :userName

  def initialize
    @groups = []
    @policies = []
    @resource_type = 'AWS::IAM::User'
  end
end
