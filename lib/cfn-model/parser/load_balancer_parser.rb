class LoadBalancerParser
  def parse(cfn_model:, resource:)
    load_balancer = resource

    load_balancer.security_groups = load_balancer.securityGroups.map do |security_group_reference|
      cfn_model.find_security_group_by_group_id(security_group_reference)
    end
    load_balancer
  end
end
