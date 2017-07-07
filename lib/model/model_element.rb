
module AWS
  module CloudFormation

  end

  module EC2

  end

  module IAM

  end

  module S3

  end

  module SNS

  end

  module SQS

  end
end

class ModelElement
  attr_accessor :logical_resource_id, :resource_type

  # def method_missing(method_name, *args)
  #   if method_name =~ /^(\w+)=$/
  #     instance_variable_set "@#{$1}", args[0]
  #   else
  #     instance_variable_get "@#{method_name}"
  #   end
  # end

  # def direct_parse_properties(properties_hash)
  #   properties_hash.each do |property_name, property_value|
  #     self.send("#{initialLower(property_name)}=", property_value)
  #   end
  # end
  #
  # def initialLower(str)
  #   str.slice(0).downcase + str[1..(str.length)]
  # end

  def to_s
    <<-END
    {
      logical_resource_id: #{@logical_resource_id}
      #{emit_instance_vars}
    }
    END
  end

  def ==(another_model_element)
    found_unequal_instance_var = false
    self.instance_variables.map { |iv| strip(iv) }.each do |instance_variable|
      if instance_variable != :logical_resource_id
        if self.send(instance_variable) != another_model_element.send(instance_variable)
          found_unequal_instance_var = true
        end
      end
    end
    !found_unequal_instance_var
  end

  private

  def strip(sym)
    sym.to_s.gsub(/@/, '').to_sym
  end

  def emit_instance_vars
    instance_vars_str = ''
    self.instance_variables.each do |instance_variable|
      instance_vars_str += "#{instance_variable}=#{instance_variable_get(instance_variable)}\n"
    end
    instance_vars_str
  end
end