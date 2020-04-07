# frozen_string_literal: true

require_relative 'parser_error'
require 'cfn-model/model/ec2_network_acl'
require 'cfn-model/model/references'
require 'cfn-model/util/truthy'

class Ec2NetworkAclParser
  def parse(cfn_model:, resource:)
    network_acl = resource
    attach_nacl_entries_to_nacl(cfn_model: cfn_model, network_acl: network_acl)
    network_acl
  end

  private

  def nacl_entries_for_nacl(cfn_model, logical_resource_id)
    network_acl_entries = cfn_model.resources_by_type('AWS::EC2::NetworkAclEntry')
                                   .select do |network_acl_entry|
      References.resolve_resource_id(network_acl_entry.networkAclId) == logical_resource_id
    end
    network_acl_entries
  end

  def attach_nacl_entries_for_nacl(cfn_model, network_acl)
    nacl_entries_for_nacl(cfn_model, network_acl.logical_resource_id).each do |network_acl_entry|
      network_acl.network_acl_entries << network_acl_entry
    end
  end

  def attach_nacl_entries_to_nacl(cfn_model:, network_acl:)
    attach_nacl_entries_for_nacl(cfn_model, network_acl)
  end
end
