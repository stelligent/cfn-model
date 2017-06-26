require_relative 'model_element'

class SecurityGroup < ModelElement
  attr_accessor :groupDescription, :vpcId
  attr_reader :securityGroupIngress, :securityGroupEgress

  def initialize
    @securityGroupIngress = []
    @securityGroupEgress = []
  end

  def add_ingress_rule(ingress_rule)
    @securityGroupIngress << ingress_rule
  end

  def add_egress_rule(egress_rule)
    @securityGroupEgress << egress_rule
  end

  def valid?(resource_name)
    raise "#{resource_name} SecurityGroup missing GroupDescription" if @groupDescription.nil?
    raise "#{resource_name} SecurityGroup missing VpcId" if @vpcId.nil?
  end

  def to_s
    <<-END
    {
      logical_resource_id: #{@logical_resource_id}
      group_description: #{@groupDescription}
      vpc_id: #{@vpcId}
      ingress_rules: #{@securityGroupIngress}
      egress_rules: #{@securityGroupEgress}
    }
    END
  end

  # don't care about the logical_resource_id?
  def ==(another_security_group)
    self.groupDescription == another_security_group.groupDescription &&
      self.vpcId == another_security_group.vpcId &&
      self.securityGroupIngress == another_security_group.securityGroupIngress &&
      self.securityGroupEgress == another_security_group.securityGroupEgress
  end
end