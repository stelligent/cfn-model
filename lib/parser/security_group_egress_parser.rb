require 'parser/direct_model'

class SecurityGroupEgressParser
  include DirectModel

  def parse(direct_model:)
    resources_by_type(direct_model: direct_model,
                      resource_type: 'AWS::EC2::SecurityGroupEgress').map do |resource_name, egress_rule|
      parse_standalone_rule(resource_name,
                            egress_rule['Properties'])
    end
  end

  def parse_inline(security_group, security_group_properties)
    return [] if security_group_properties['SecurityGroupEgress'].nil?

    if security_group_properties['SecurityGroupEgress'].is_a? Array
      security_group_properties['SecurityGroupEgress'].each do |egress_json|
        security_group.add_egress_rule parse_inline_rule(security_group.logical_resource_id,
                                                          egress_json)
      end
    elsif security_group_properties['SecurityGroupEgress'].is_a? Hash
      security_group.add_egress_rule parse_inline_rule(security_group.logical_resource_id,
                                                        security_group_properties['SecurityGroupEgress'])
    end
  end

  private

  # should parsing like this be directed from a top-level uniform schema-like mechanism?
  def parse_inline_rule(logical_resource_id, egress_hash)
    security_group_egress = SecurityGroupEgress.new

    security_group_egress.cidrIp = egress_hash['CidrIp']
    security_group_egress.cidrIpv6 = egress_hash['CidrIpv6']
    security_group_egress.destinationPrefixListId = egress_hash['DestinationPrefixListId']
    security_group_egress.destinationSecurityGroupId = egress_hash['DestinationSecurityGroupId']

    security_group_egress.fromPort = egress_hash['FromPort']
    security_group_egress.toPort = egress_hash['ToPort']
    security_group_egress.ipProtocol = egress_hash['IpProtocol']

    security_group_egress.valid? logical_resource_id
    security_group_egress
  end

  def parse_standalone_rule(logical_resource_id, egress_hash)
    security_group_egress = parse_inline_rule logical_resource_id, egress_hash

    security_group_egress.groupId = egress_hash['GroupId']

    security_group_egress.logical_resource_id = logical_resource_id

    security_group_egress.valid_standalone? logical_resource_id
    security_group_egress
  end
end
