# frozen_string_literal: true

require_relative 'model_element'

class AWS::IAM::User  < ModelElement
  # synthesized version of policies
  attr_accessor :policy_objects, :group_names

  def initialize(cfn_model)
    super
    @groups = []
    @policies = []
    @policy_objects = []
    @group_names = []
    @resource_type = 'AWS::IAM::User'
  end
end
