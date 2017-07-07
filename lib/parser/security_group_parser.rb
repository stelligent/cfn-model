require_relative 'parser_error'
require 'model/security_group_egress'
require 'model/security_group_ingress'
require 'model/references'

class SecurityGroupParser

  def parse(cfn_model:, resource:)
     security_group = resource

     if security_group.securityGroupEgress.is_a? Hash
       security_group.securityGroupEgress = [security_group.securityGroupEgress]
     end

     security_group.securityGroupEgress = security_group.securityGroupEgress.map do |egress|
       egress_object = SecurityGroupEgress.new
       egress.each do |k,v|
         egress_object.send("#{initialLower(k)}=", v)
       end
       egress_object
     end

     if security_group.securityGroupIngress.is_a? Hash
       security_group.securityGroupIngress = [security_group.securityGroupIngress]
     end

     security_group.securityGroupIngress = security_group.securityGroupIngress.map do |ingress|
       ingress_object = SecurityGroupIngress.new
       ingress.each do |k,v|
         ingress_object.send("#{initialLower(k)}=", v)
       end
       # call valid?
       ingress_object
     end

     wire_ingress_rules_to_security_group(cfn_model: cfn_model, security_group: security_group)
     wire_egress_rules_to_security_group(cfn_model: cfn_model, security_group: security_group)
     security_group
  end

  private

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
        security_group.securityGroupIngress << security_group_ingress
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
        security_group.securityGroupEgress << security_group_egress
      end
    end
  end
end