require 'parser/direct_model'

class SecurityGroupIngressParser
  include DirectModel

  def parse(direct_model:)
    resources_by_type(direct_model: direct_model,
                      resource_type: 'AWS::EC2::SecurityGroupIngress').map do |resource_name, ingress_rule|
      parse_standalone_rule(resource_name,
                            ingress_rule['Properties'])
    end
  end

  def parse_inline(security_group, security_group_properties)
    return [] if security_group_properties['SecurityGroupIngress'].nil?

    if security_group_properties['SecurityGroupIngress'].is_a? Array
      security_group_properties['SecurityGroupIngress'].each do |ingress_json|
        security_group.add_ingress_rule parse_inline_rule(security_group.logical_resource_id,
                                                          ingress_json)
      end
    elsif security_group_properties['SecurityGroupIngress'].is_a? Hash
      security_group.add_ingress_rule parse_inline_rule(security_group.logical_resource_id,
                                                        security_group_properties['SecurityGroupIngress'])
    end
  end

  private

  # should parsing like this be directed from a top-level uniform schema-like mechanism?
  def parse_inline_rule(logical_resource_id, ingress_hash)
    security_group_ingress = SecurityGroupIngress.new

    security_group_ingress.cidrIp = ingress_hash['CidrIp']
    security_group_ingress.cidrIpv6 = ingress_hash['CidrIpv6']
    security_group_ingress.sourceSecurityGroupName = ingress_hash['SourceSecurityGroupName']
    security_group_ingress.sourceSecurityGroupId = ingress_hash['SourceSecurityGroupId']

    security_group_ingress.fromPort = ingress_hash['FromPort']
    security_group_ingress.toPort = ingress_hash['ToPort']
    security_group_ingress.ipProtocol = ingress_hash['IpProtocol']


    security_group_ingress.sourceSecurityGroupOwnerId = ingress_hash['SourceSecurityGroupOwnerId']

    security_group_ingress.valid? logical_resource_id

    security_group_ingress
  end

  def parse_standalone_rule(logical_resource_id, ingress_hash)
    security_group_ingress = parse_inline_rule logical_resource_id, ingress_hash

    security_group_ingress.groupId = ingress_hash['GroupId']
    security_group_ingress.groupName = ingress_hash['GroupName']

    security_group_ingress.logical_resource_id = logical_resource_id

    security_group_ingress.valid_standalone? logical_resource_id
    security_group_ingress
  end
end
