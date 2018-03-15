require_relative 'model_element'

# this could have been inline or freestanding
# in latter case there would be a logical resource id
# but i think we don't ever care?
class AWS::EC2::SecurityGroupIngress < ModelElement
  # You must specify a source security group (SourceSecurityGroupName or SourceSecurityGroupId) or a CIDR range (CidrIp or CidrIpv6).
  attr_accessor :cidrIp,
                :cidrIpv6,
                :sourceSecurityGroupName,
                :sourceSecurityGroupId

  # Required: Conditional. You must specify the GroupName property or the GroupId property.
  # For security groups that are in a VPC, you must use the GroupId property. For example, EC2-VPC accounts must use the GroupId property.
  # this will be nil for inline ingress rules
  attr_accessor :groupId,
                :groupName

  # Required: Conditional from/To required when IP Protocol is explicitly specified (TCP, ICMP, etc), not required when using all protocols (ie -1)
  attr_accessor :fromPort,
                :toPort,
                :ipProtocol

  # Required: Conditional. If you specify SourceSecurityGroupName and that security group is owned by a different
  # account than the account creating the stack, you must specify the SourceSecurityGroupOwnerId; otherwise, this property is optional.
  attr_accessor :sourceSecurityGroupOwnerId

  def initialize
    @resource_type = 'AWS::EC2::SecurityGroupIngress'
  end

  # def valid?
  #   has_no_source = @cidrIp.nil? && @cidrIpv6.nil? && @sourceSecurityGroupName.nil? && @sourceSecurityGroupId.nil?
  #   if has_no_source
  #     raise "SG ingress #{@logical_resource_id} has no source specified"
  #   end
  # end
end
