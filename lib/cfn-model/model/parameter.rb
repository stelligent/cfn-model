# frozen_string_literal: true

class Parameter
  attr_accessor :id, :type

  attr_accessor :synthesized_value

  def is_no_echo?
    !@noEcho.nil? && @noEcho.to_s.downcase == 'true'
  end

  def to_s
    <<END
{
#{emit_instance_vars}
}
END
  end

  ##
  # Treat any missing method as an instance variable get/set
  #
  # This will allow arbitrary elements in Resource/Properties definitions
  # to map to instance variables without having to anticipate them in a schema
  def method_missing(method_name, *args)
    if method_name =~ /^(\w+)=$/
      instance_variable_set "@#{$1}", args[0]
    else
      instance_variable_get "@#{method_name}"
    end
  end

  def emit_instance_vars
    instance_vars_str = ''
    instance_variables.each do |instance_variable|
      instance_vars_str += "  #{instance_variable}=#{instance_variable_get(instance_variable)}\n"
    end
    instance_vars_str
  end
end
