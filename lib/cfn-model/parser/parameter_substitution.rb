# frozen_string_literal: true

require 'json'

class ParameterSubstitution
  PARAMETER_KEY = 'ParameterKey'
  PARAMETER_VALUE = 'ParameterValue'
  PARAMETERS = 'Parameters'

  def apply_parameter_values(cfn_model, parameter_values_json)
    unless parameter_values_json.nil?
      parameter_values = JSON.parse parameter_values_json
      if aws_format?(parameter_values)
        parameter_values = convert_aws_to_legacy_format(parameter_values)
      elsif !legacy_format?(parameter_values)
        format_error = "JSON parameters must be a dictionary with key \"#{PARAMETERS}\" "\
                       'or an array of ParameterKey/ParameterValue dictionaries'
        raise JSON::ParserError, format_error
      end
      apply_parameter_values_impl cfn_model, parameter_values
    end
  end

  private

  def convert_aws_to_legacy_format(parameter_values)
    legacy_format = {
      PARAMETERS => {}
    }
    parameter_values.each_with_object(legacy_format) do |parameter_value, result|
      result[PARAMETERS][parameter_value[PARAMETER_KEY]] = parameter_value[PARAMETER_VALUE]
      result
    end
  end

  def apply_parameter_values_impl(cfn_model, parameter_values)
    parameter_values[PARAMETERS].each do |parameter_name, parameter_value|
      if cfn_model.parameters.key?(parameter_name)
        cfn_model.parameters[parameter_name].synthesized_value = parameter_value.to_s
      end
      # not going to complain if there are extra parameters in JSON.... if doing a scan
      # you only have one file for all the templates
    end

    # any leftovers get default value
    # if external values were specified, we take that as a cue to consider defaults
    # if no external values, we will ignore default values
    cfn_model.parameters.each do |_, parameter|
      if parameter.synthesized_value.nil? && !parameter.default.nil?
        parameter.synthesized_value = parameter.default.to_s
      end
    end
  end

  def aws_format?(parameter_values)
    return false unless parameter_values.is_a?(Array)

    !parameter_values.find do |parameter_value|
      !parameter_value['ParameterKey'] || !parameter_value['ParameterValue']
    end
  end

  def legacy_format?(parameter_values)
    parameter_values.is_a?(Hash) && parameter_values.key?(PARAMETERS)
  end
end
