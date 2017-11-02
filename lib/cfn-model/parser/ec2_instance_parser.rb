class Ec2InstanceParser
  def parse(cfn_model:, resource:)
    ec2_instance = resource

    if ec2_instance.securityGroupIds.is_a? Array
      ec2_instance.security_groups = ec2_instance.securityGroupIds.map do |security_group_reference|
        cfn_model.find_security_group_by_group_id(security_group_reference)
      end
    else
      # could be a Ref to a List<AWS::EC2::SecurityGroup::Id> which we can't
      # do much with at the level of static analysis before knowing the parameter passed in
      # worth checking defaults?
      ec2_instance.security_groups = []
    end
    ec2_instance
  end
end
