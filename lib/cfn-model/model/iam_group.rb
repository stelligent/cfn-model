# frozen_string_literal: true

require_relative 'model_element'

class AWS::IAM::Group < ModelElement
  # synthesized version of policies
  attr_accessor :policy_objects

  def initialize(cfn_model)
    super
    @managedPolicyArns = []
    @policies = []
    @policy_objects = []
    @resource_type = 'AWS::IAM::Group'
  end
end
