class CfnModel
  attr_reader :resources

  def initialize
    @resources = {}
  end

  def security_groups
    resources_by_type 'AWS::EC2::SecurityGroup'
  end

  def iam_users
    resources_by_type 'AWS::IAM::User'
  end

  def standalone_ingress
    ingress_rules = cfn_model.resources_by_type 'AWS::EC2::SecurityGroupIngress'
    ingress_rules.select do |security_group_ingress|
      References.is_security_group_id_external(security_group_ingress.groupId)
    end
  end

  def standalone_egress
    egress_rules = cfn_model.resources_by_type 'AWS::EC2::SecurityGroupEgress'
    egress_rules.select do |security_group_egress|
      References.is_security_group_id_external(security_group_egress.groupId)
    end
  end

  def resources_by_type(resource_type)
    @resources.values.select { |resource| resource.resource_type == resource_type }
  end
end