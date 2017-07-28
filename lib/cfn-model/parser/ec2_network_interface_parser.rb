class Ec2NetworkInterfaceParser
  def parse(cfn_model:, resource:)
    network_interface = resource

    network_interface.security_groups = network_interface.groupSet.map do |security_group_reference|
      cfn_model.find_security_group_by_group_id(security_group_reference)
    end
    network_interface
  end
end
