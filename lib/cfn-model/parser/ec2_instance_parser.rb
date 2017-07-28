class Ec2InstanceParser
  def parse(cfn_model:, resource:)
    ec2_instance = resource

    ec2_instance.security_groups = ec2_instance.securityGroupIds.map do |security_group_reference|
      cfn_model.find_security_group_by_group_id(security_group_reference)
    end
    ec2_instance
  end
end
