require 'parser/direct_model'
require_relative 'security_group_ingress_parser'
require_relative 'security_group_egress_parser'

class SecurityGroupParser
  include DirectModel

  ##
  # Given a "direct model" of a Hash parsed from a Json document
  # return an array of "synthesized" SecurityGroup objects
  ##
  def parse(direct_model:)
    security_groups = []
    security_group_hashes = resources_by_type direct_model: direct_model,
                                              resource_type: 'AWS::EC2::SecurityGroup'

    security_group_hashes.each do |resource_name, security_group_hash|
      security_groups << parse_security_group_properties(resource_name, security_group_hash['Properties'])
    end
    wire_ingress_rules_to_security_groups(direct_model, security_groups)
    wire_egress_rules_to_security_groups(direct_model, security_groups)
    security_groups
  end

  protected

  def resolve_group_id(group_id)
    raise 'type specific'
  end

  private

  def parse_security_group_properties(resource_name, properties)
    security_group = SecurityGroup.new
    security_group.vpcId = properties['VpcId']
    security_group.groupDescription = properties['GroupDescription']
    security_group.logical_resource_id = resource_name

    ingress_parser = SecurityGroupIngressParser.new
    ingress_parser.parse_inline security_group, properties

    egress_parser = SecurityGroupEgressParser.new
    egress_parser.parse_inline security_group, properties

    security_group.valid? resource_name
    security_group
  end

  def find_security_group(security_groups, logical_resource_id)
    security_groups.find { |security_group| security_group.logical_resource_id == logical_resource_id }
  end

  def wire_ingress_rules_to_security_groups(direct_model, security_groups)
    ingress_rules = SecurityGroupIngressParser.new.parse direct_model: direct_model
    ingress_rules.each do |security_group_ingress|
      group_id = resolve_group_id(security_group_ingress.groupId)

      # standalone ingress rules are legal - referencing an external security group
      next if group_id.nil?

      container_security_group = find_security_group security_groups, group_id
      if !container_security_group.nil?
        container_security_group.add_ingress_rule security_group_ingress
      else
        raise ParserError.new("Ingress referencing non-existent security group: #{group_id}")
      end
    end
  end

  def wire_egress_rules_to_security_groups(direct_model, security_groups)
    egress_rules = SecurityGroupEgressParser.new.parse direct_model: direct_model
    egress_rules.each do |security_group_egress|
      group_id = resolve_group_id(security_group_egress.groupId)

      # standalone ingress rules are legal - referencing an external security group
      next if group_id.nil?

      container_security_group = find_security_group security_groups, group_id
      if !container_security_group.nil?
        container_security_group.add_egress_rule security_group_egress
      else
        raise ParserError.new("Egress referencing non-existent security group: #{group_id}")
      end
    end
  end
end