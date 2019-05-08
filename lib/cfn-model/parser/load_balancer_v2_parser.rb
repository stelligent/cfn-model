class LoadBalancerV2Parser
  def parse(cfn_model:, resource:)
    load_balancer = resource

    #could be a List<Subnet::Id>
    # if load_balancer.subnets.size < 2
    #   raise ParserError.new("Load Balancer must have at least two subnets: #{load_balancer.logical_resource_id}")
    # end

    if load_balancer.securityGroups.is_a? Array
      load_balancer.security_groups = load_balancer.securityGroups.map do |security_group_reference|
        cfn_model.find_security_group_by_group_id(security_group_reference)
      end
    else
      # er... list of ids or comma separated list.  just punt.
      load_balancer.security_groups = []
    end
    load_balancer
  end
end
