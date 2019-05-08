require_relative 'parser_error'
require 'cfn-model/model/security_group_egress'
require 'cfn-model/model/security_group_ingress'
require 'cfn-model/model/references'

class SecurityGroupParser

  def parse(cfn_model:, resource:)
     security_group = resource

     objectify_egress cfn_model, security_group

     objectify_ingress cfn_model, security_group

     wire_ingress_rules_to_security_group(cfn_model: cfn_model, security_group: security_group)
     wire_egress_rules_to_security_group(cfn_model: cfn_model, security_group: security_group)
     security_group
  end

  private

  def silently_fail
    begin
      yield
    rescue
    end
  end

  def objectify_ingress(cfn_model, security_group)
    if security_group.securityGroupIngress.is_a? Hash
      security_group.securityGroupIngress = [security_group.securityGroupIngress]
    end

    security_group.ingresses = security_group.securityGroupIngress.map do |ingress|
      mapped_at_least_one_attribute = false
      ingress_object = AWS::EC2::SecurityGroupIngress.new cfn_model
      ingress.each do |k,v|
        silently_fail do
          ingress_object.send("#{initialLower(k)}=", v)
          mapped_at_least_one_attribute = true
        end
      end
      #ingress_object.valid?
      mapped_at_least_one_attribute ? ingress_object : nil
    end.reject { |ingress| ingress.nil? }
  end

  def objectify_egress(cfn_model, security_group)
    if security_group.securityGroupEgress.is_a? Hash
      security_group.securityGroupEgress = [security_group.securityGroupEgress]
    end

    security_group.egresses = security_group.securityGroupEgress.map do |egress|
      mapped_at_least_one_attribute = false

      egress_object = AWS::EC2::SecurityGroupEgress.new cfn_model
      egress.each do |k,v|
        next if k.match /::/
        silently_fail do
          egress_object.send("#{initialLower(k)}=", v)
          mapped_at_least_one_attribute = true
        end

      end.reject { |ingress| ingress.nil? }
      #egress_object.valid?
      egress_object
      mapped_at_least_one_attribute ? egress_object : nil
    end
  end

  def initialLower(str)
    str.slice(0).downcase + str[1..(str.length)]
  end

  def wire_ingress_rules_to_security_group(cfn_model:, security_group:)
    ingress_rules = cfn_model.resources_by_type 'AWS::EC2::SecurityGroupIngress'
    ingress_rules.each do |security_group_ingress|
      group_id = References.resolve_security_group_id(security_group_ingress.groupId)

      # standalone ingress rules are legal - referencing an external security group
      next if group_id.nil?

      if security_group.logical_resource_id == group_id
        security_group.ingresses << security_group_ingress
      end
    end
  end

  def wire_egress_rules_to_security_group(cfn_model:, security_group:)
    egress_rules = cfn_model.resources_by_type 'AWS::EC2::SecurityGroupEgress'
    egress_rules.each do |security_group_egress|
      group_id = References.resolve_security_group_id(security_group_egress.groupId)

      # standalone ingress rules are legal - referencing an external security group
      next if group_id.nil?

      if security_group.logical_resource_id == group_id
        security_group.egresses << security_group_egress
      end
    end
  end
end