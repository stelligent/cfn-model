require_relative 'model_element'

# this could have been inline or freestanding
# in latter case there would be a logical resource id
# but i think we don't ever care?
class SecurityGroupEgress < ModelElement
  # You must specify a destination security group (destinationPrefixListId or destinationSecurityGroupId) or a CIDR range (CidrIp or CidrIpv6).
  attr_accessor :cidrIp,
                :cidrIpv6,
                :destinationPrefixListId,
                :destinationSecurityGroupId

  # required
  attr_accessor :groupId,
                :fromPort,
                :toPort,
                :ipProtocol

  def valid?(logical_resource_id)
    has_no_destination = @cidrIp.nil? && @cidrIpv6.nil? && @destinationPrefixListId.nil? && @destinationSecurityGroupId.nil?
    if has_no_destination
      raise "SG egress #{logical_resource_id} has no destination specified"
    end

    missing_protocol = @fromPort.nil? || @toPort.nil? || @ipProtocol.nil?
    if missing_protocol
      raise "SG egress #{logical_resource_id} missing protocol, from or to port"
    end
  end

  def valid_standalone?(logical_resource_id)
    valid? logical_resource_id
    if @groupId.nil?
      raise "SG egress #{logical_resource_id} has no GroupId"
    end
  end

  def ==(another_security_group)
    self.cidrIp == another_security_group.cidrIp &&
      self.cidrIpv6 == another_security_group.cidrIpv6 &&
      self.destinationPrefixListId == another_security_group.destinationPrefixListId &&
      self.destinationSecurityGroupId == another_security_group.destinationSecurityGroupId &&
      self.groupId == another_security_group.groupId &&
      self.fromPort == another_security_group.fromPort &&
      self.toPort == another_security_group.toPort &&
      self.ipProtocol == another_security_group.ipProtocol
  end
end
