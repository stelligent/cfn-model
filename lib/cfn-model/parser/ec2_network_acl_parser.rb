# frozen_string_literal: true

require_relative 'parser_error'
require 'cfn-model/model/ec2_network_acl'
require 'cfn-model/model/references'

class Ec2NetworkAclParser
  def parse(cfn_model:, resource:)
    network_acl = resource

    attach_nacl_entries_to_nacl(cfn_model: cfn_model, network_acl: network_acl)
    network_acl
  end

  private

  def egress_network_acl_entries(cfn_model)
    network_acl_entries = cfn_model.resources_by_type 'AWS::EC2::NetworkAclEntry'
    network_acl_entries.select(&:egress)
  end

  def ingress_network_acl_entries(cfn_model)
    network_acl_entries = cfn_model.resources_by_type 'AWS::EC2::NetworkAclEntry'
    network_acl_entries.select do |network_acl_entry|
      network_acl_entry.egress.nil? || !network_acl_entry.egress
    end
  end

  def egress_nacl_entries_for_nacl(cfn_model, logical_resource_id)
    egress_nacl_entries = egress_network_acl_entries(cfn_model)
    egress_nacl_entries.select do |egress_nacl_entry|
      References.resolve_resource_id(egress_nacl_entry.networkAclId) == logical_resource_id
    end
  end

  def ingress_nacl_entries_for_nacl(cfn_model, logical_resource_id)
    ingress_nacl_entries = ingress_network_acl_entries(cfn_model)
    ingress_nacl_entries.select do |ingress_nacl_entry|
      References.resolve_resource_id(ingress_nacl_entry.networkAclId) == logical_resource_id
    end
  end

  def attach_nacl_entries_for_nacl(cfn_model, network_acl)
    egress_nacl_entries_for_nacl(cfn_model, network_acl.logical_resource_id).each do |egress_entry|
      network_acl.network_acl_egress_entries << egress_entry.logical_resource_id
    end
    ingress_nacl_entries_for_nacl(cfn_model, network_acl.logical_resource_id).each do |ingress_entry|
      network_acl.network_acl_ingress_entries << ingress_entry.logical_resource_id
    end
  end

  def attach_nacl_entries_to_nacl(cfn_model:, network_acl:)
    attach_nacl_entries_for_nacl(cfn_model, network_acl)
  end
end
