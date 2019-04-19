# frozen_string_literal: true

require_relative 'model_element'

class AWS::IAM::ManagedPolicy < ModelElement
  attr_accessor :policy_document

  def initialize(cfn_model)
    super
    @groups = []
    @roles = []
    @users = []
    @resource_type = 'AWS::IAM::ManagedPolicy'
  end
end
