# frozen_string_literal: true

require_relative 'model_element'

# this could have been inline or freestanding
# in latter case there would be a logical resource id
# but i think we don't ever care?
class AWS::EC2::SecurityGroupEgress < ModelElement
  def initialize(cfn_model)
    super
    @resource_type = 'AWS::EC2::SecurityGroupEgress'
  end
end
