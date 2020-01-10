# frozen_string_literal: true

require_relative 'references'

module AWS
  module CloudFormation

  end

  module EC2

  end

  module ElasticLoadBalancing

  end

  module ElasticLoadBalancingV2

  end

  module IAM

  end

  module KMS

  end

  module S3

  end

  module SNS

  end

  module SQS

  end

  module Lambda

  end

  module CloudFront

  end
end

module Custom

end

#ModelElement is a bit of a misnomer I think.... this is really a Resource, and Parameter and Resource
#have a lot in common, but are different
class ModelElement
  attr_accessor :logical_resource_id, :resource_type, :metadata

  # the dreaded two way relationship
  def initialize(cfn_model)
    raise 'cfn_model must be specificed' if cfn_model.nil?
    @cfn_model = cfn_model
  end

  def to_s
    <<END
{
#{emit_instance_vars}
}
END
  end

  def ==(another_model_element)
    found_unequal_instance_var = false
    instance_variables_without_at_sign.each do |instance_variable|
      if instance_variable != :logical_resource_id && instance_variable != :cfn_model
        if self.send(instance_variable) != another_model_element.send(instance_variable)
          found_unequal_instance_var = true
        end
      end
    end
    !found_unequal_instance_var
  end

  private

  ##
  # Treat any missing method as an instance variable get/set
  #
  # This will allow arbitrary elements in Resource/Properties definitions
  # to map to instance variables without having to anticipate them in a schema
  def method_missing(method_name, *args)
    if method_name =~ /^(\w+)=$/
      instance_variable_set "@#{$1}", args[0]
    else
      References.resolve_value(@cfn_model, instance_variable_get("@#{method_name}"))
    end
  end

  def instance_variables_without_at_sign
    self.instance_variables.map { |instance_variable| strip(instance_variable) }
  end

  def strip(sym)
    sym.to_s.gsub(/@/, '').to_sym
  end

  def emit_instance_vars
    instance_vars_str = ''
    self.instance_variables.each do |instance_variable|
      instance_vars_str += "  #{instance_variable}=#{instance_variable_get(instance_variable)}\n"
    end
    instance_vars_str
  end
end
