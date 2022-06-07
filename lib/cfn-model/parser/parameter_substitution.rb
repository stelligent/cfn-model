# frozen_string_literal: true

require 'json'

class ParameterSubstitution
  PARAMETER_KEY = 'ParameterKey'
  PARAMETER_VALUE = 'ParameterValue'
  PARAMETERS = 'Parameters'

  def apply_parameter_values(cfn_model, parameter_values_json)
    unless parameter_values_json.nil?
      parameter_values = JSON.parse parameter_values_json
      if is_aws_format?(parameter_values)
        parameter_values = convert_aws_to_legacy_format(parameter_values)
      elsif !is_legacy_format?(parameter_values)
        format_error = "JSON parameters must be a dictionary with key \"#{PARAMETERS}\" "\
                       "or an array of ParameterKey/ParameterValue dictionaries"
        raise JSON::ParserError.new(format_error)
      end
      apply_parameter_values_impl cfn_model, parameter_values
    end
  end

  private

  def convert_aws_to_legacy_format(parameter_values)
    legacy_format = {
      PARAMETERS => {}
    }
    parameter_values.reduce(legacy_format) do |result, parameter_value|
      result[PARAMETERS][parameter_value[PARAMETER_KEY]] = parameter_value[PARAMETER_VALUE]
      result
    end
  end

  def apply_pseudo_parameter_values(cfn_model, parameter_values)
    # leave out 'AWS::NoValue'? not sure - we explicitly check it in some places...
    # might make sense to substitute here?
    pseudo_function_defaults = {
      'AWS::URLSuffix' => 'amazonaws.com',
      'AWS::Partition' => 'aws',
      'AWS::NotificationARNs' => '',
      'AWS::AccountId' => '111111111111',
      'AWS::Region' => 'us-east-1',
      'AWS::StackId' => 'arn:aws:cloudformation:us-east-1:111111111111:stack/stackname/51af3dc0-da77-11e4-872e-1234567db123',
      'AWS::StackName' => 'stackname',
      'AWS::NumberAZs' => 2
    }
    pseudo_function_defaults.each do |function_name, default_value|
      parameter = Parameter.new
      parameter.id = function_name
      parameter.type = 'String'
      cfn_model.parameters[function_name] = parameter

      if parameter_values[PARAMETERS].has_key?(function_name)
        parameter.synthesized_value = parameter_values[PARAMETERS][function_name]
      else
        parameter.synthesized_value = default_value
      end
    end
  end

  def apply_parameter_values_impl(cfn_model, parameter_values)
    parameter_values[PARAMETERS].each do |parameter_name, parameter_value|
      if cfn_model.parameters.has_key?(parameter_name)
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
    apply_pseudo_parameter_values(cfn_model, parameter_values)
  end

  def is_aws_format?(parameter_values)
    return false unless parameter_values.is_a?(Array)
    !parameter_values.find do |parameter_value|
      !parameter_value['ParameterKey'] || !parameter_value['ParameterValue']
    end
  end

  def is_legacy_format?(parameter_values)
    parameter_values.is_a?(Hash) && parameter_values.has_key?(PARAMETERS)
  end
end