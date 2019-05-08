require_relative 'model_element'

class AWS::S3::BucketPolicy  < ModelElement
  # PolicyDocument - objectified policyDocument
  attr_accessor :policy_document

  def initialize(cfn_model)
    super
    @resource_type = 'AWS::S3::BucketPolicy'
  end
end
