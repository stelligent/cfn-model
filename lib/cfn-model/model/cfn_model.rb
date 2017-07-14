require_relative 'references'

class CfnModel
  attr_reader :resources

  ##
  # if you really want it, here it is - the raw Hash from YAML.load.  you'll have to mess with structural nits of
  # CloudFormation and deal with variations between yaml/json refs and all that
  #
  attr_accessor :raw_model

  def initialize
    @resources = {}
    @raw_model = nil
  end

  def security_groups
    resources_by_type 'AWS::EC2::SecurityGroup'
  end

  def iam_users
    resources_by_type 'AWS::IAM::User'
  end

  def standalone_ingress
    security_group_ingresses = resources_by_type 'AWS::EC2::SecurityGroupIngress'
    security_group_ingresses.select do |security_group_ingress|
      References.is_security_group_id_external(security_group_ingress.groupId)
    end
  end

  def standalone_egress
    security_group_egresses = resources_by_type 'AWS::EC2::SecurityGroupEgress'
    security_group_egresses.select do |security_group_egress|
      References.is_security_group_id_external(security_group_egress.groupId)
    end
  end

  def resources_by_type(resource_type)
    @resources.values.select { |resource| resource.resource_type == resource_type }
  end

  def to_s
    @resources.to_s
  end
end