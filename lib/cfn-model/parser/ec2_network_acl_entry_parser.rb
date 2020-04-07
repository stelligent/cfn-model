# frozen_string_literal: true

require_relative 'parser_error'
require 'cfn-model/model/ec2_network_acl_entry'
require 'cfn-model/model/references'
require 'cfn-model/util/truthy'

class Ec2NetworkAclEntryParser
  def parse(resource:)
    ec2_network_acl_entry = resource

    ec2_network_acl_entry.icmp = [] unless ec2_network_acl_entry.icmp.is_a? Array
    ec2_network_acl_entry.portRange = [] unless ec2_network_acl_entry.portRange.is_a? Array

    ec2_network_acl_entry
  end
end
