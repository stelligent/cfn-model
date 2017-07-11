require_relative 'model_element'

class AWS::S3::BucketPolicy  < ModelElement
  attr_accessor :bucket, :policyDocument

  def initialize
    @resource_type = 'AWS::S3::BucketPolicy'
  end
end
