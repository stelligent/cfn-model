# frozen_string_literal: true

require 'cfn-model/parser/parser_error'
require 'netaddr'

##
# this is a placeholder for anything related to resolving references
#
# not sure if we are going to be able to have a useful generic set of code for
# references yet... in the meantime pile things up here and hope a pattern becomes
# clear
module References
  def self.unsupported_passthru?(value)
    value.has_key?('Fn::GetAtt') || value.has_key?('Fn::ImportValue') || value.has_key?('Fn::Transform') || value.has_key?('Fn::Cidr')
  end

  def self.resolve_value(cfn_model, value)
    if value.is_a? Hash
      if value.has_key?('Ref')
        resolve_reference(cfn_model, value)
      elsif value.has_key?('Fn::FindInMap')
        resolve_map(cfn_model, value)
      elsif value.has_key?('Fn::If')
        resolve_if(cfn_model, value)
      elsif value.has_key?('Fn::Sub')
        resolve_sub(cfn_model, value)
      elsif value.has_key?('Fn::GetAZs')
        resolve_getazs(cfn_model, value)
      elsif value.has_key?('Fn::Split')
        resolve_split(cfn_model, value)
      elsif value.has_key?('Fn::Join')
        resolve_join(cfn_model, value)
      elsif value.has_key?('Fn::Base64')
        resolve_base64(cfn_model, value)
      elsif value.has_key?('Fn::Select')
        resolve_select(cfn_model, value)
      elsif unsupported_passthru?(value)
        value
      else # another mapping
        value.map do |k,v|
          [k, resolve_value(cfn_model, v)]
        end.to_h
      end
    elsif value.is_a? Array
      value.map { |item| resolve_value(cfn_model, item) }
    else
      value
    end
  end

  ##
  # For a !Ref to another resource.... just returns the !REf
  # For a !Ref to a Parameter, then try to synthesize the value
  def self.resolve_reference(cfn_model, value)
    ref_id = value['Ref']
    if ref_id.is_a? String
      if cfn_model.parameters.has_key?(ref_id)
        return value if cfn_model.parameters[ref_id].synthesized_value.nil?
        return cfn_model.parameters[ref_id].synthesized_value
      else
        return value
      end
    else
      value
    end
  end

  def self.resolve_resource_id(reference, attr = nil)
    return nil if reference.is_a? String

    # an imported value can only yield a literal to an external resource vs. referencing something local
    if !reference['Ref'].nil?
      reference['Ref']
    elsif !reference['Fn::GetAtt'].nil?
      logical_resource_id_from_get_att reference['Fn::GetAtt'], attr
    else
      # anything else will be string manipulation functions
      # which again leads us back to a string which must be an external resource known out of band
      # so don't/can't link it up
      return nil
    end
  rescue NoMethodError => e
    raise ParserError, e.inspect
  end

  def self.is_security_group_id_external(group_id)
    resolve_security_group_id(group_id).nil?
  end

  def self.resolve_security_group_id(group_id)
    resolve_resource_id group_id, 'GroupId'
  end

  ##
  # Try to compute the FindInMap against a real Mapping
  #
  # If anything doesn't match up - either a syntax error,
  # a missing Mapping, or some other kind Cfn evaluation
  # we don't understand, just return the call to FindInMap
  def self.resolve_map(cfn_model, find_in_map)
    map_name = find_in_map['Fn::FindInMap'][0]
    top_level_key = find_in_map['Fn::FindInMap'][1]
    second_level_key = find_in_map['Fn::FindInMap'][2]

    map = cfn_model.mappings[map_name]

    return find_in_map if map.nil?

    top_level_resolved = resolve_value(cfn_model, top_level_key)

    return find_in_map if !map.has_key?(top_level_resolved)

    top_level = map[top_level_resolved]
    second_level = top_level[resolve_value(cfn_model, second_level_key)]

    return find_in_map if second_level.nil?

    second_level
  end

  private

  def self.resolve_sub(cfn_model, expression)
    if expression['Fn::Sub'].is_a? String
      resolve_shorthand_sub(cfn_model, expression)
    elsif expression['Fn::Sub'].is_a? Array
      resolve_longform_sub(cfn_model, expression)
    else
      expression
    end
  end

  def self.resolve_select(cfn_model, reference)
    index = reference['Fn::Select'][0]
    collection = References.resolve_value(cfn_model, reference['Fn::Select'][1])
    if collection.is_a? Array
      collection[index]
    else
      reference
    end
  end

  def self.resolve_base64(cfn_model, reference)
    References.resolve_value(cfn_model, reference['Fn::Base64'])
  end

  def self.resolve_join(cfn_model, reference)
    delimiter = reference['Fn::Join'][0]
    items = References.resolve_value(cfn_model, reference['Fn::Join'][1])
    return reference unless items.is_a?(Array)
    items.join(delimiter)
  end

  def self.resolve_split(cfn_model, reference)
    delimiter = reference['Fn::Split'][0]
    target_string = References.resolve_value(cfn_model, reference['Fn::Split'][1])
    return reference unless target_string.is_a?(String)
    target_string.split(delimiter)
  end

  def self.resolve_getazs(cfn_model, reference)
    number_azs = References.resolve_value(cfn_model, { 'Ref' => 'AWS::NumberAZs' })
    region = reference['Fn::GetAZs']
    if region == '' || region == { 'Ref' => 'AWS::Region' }
      region = References.resolve_value(cfn_model, { 'Ref' => 'AWS::Region' })
    end
    (('a'.ord)..('a'.ord+number_azs)).map do |az_number|
      "#{region}#{az_number.chr}"
    end
  end

  def self.strip_cfn_interpolation(reference)
    reference[2..-2]
  end

  def self.references_in_sub(string_value)
    # ignore ${!foo} as cfn interprets that as the literal ${foo}
    references = string_value.scan /\${[^!].*?}/
    references.map { |reference| strip_cfn_interpolation(reference) }
  end

  def self.resolvable_reference?(cfn_model, reference)
    resolved_value = References.resolve_value(cfn_model, {'Ref'=>reference})
    resolved_value != {'Ref'=>reference}
  end

  def self.resolve_shorthand_sub(cfn_model, expression)
    string_value = expression['Fn::Sub']
    subbed_string_value = string_value
    has_unresolved_references = false
    references_in_sub(string_value).each do |reference|
      if resolvable_reference?(cfn_model, reference)
        subbed_string_value = subbed_string_value.gsub(
          "${#{reference}}",
          References.resolve_value(cfn_model, {'Ref'=>reference})
        )
      end
    end
    subbed_string_value
  end

  def self.resolve_longform_sub(cfn_model, expression)
    array_value = expression['Fn::Sub']
    subbed_string_value = array_value[0]
    substitution_mapping = array_value[1]
    references_in_sub(subbed_string_value).each do |reference|
      if substitution_mapping.has_key? reference
        if References.resolve_value(cfn_model, substitution_mapping[reference]).is_a?(String)
          subbed_string_value = subbed_string_value.gsub(
            "${#{reference}}",
            References.resolve_value(cfn_model, substitution_mapping[reference])
          )
        end
      elsif resolvable_reference?(cfn_model, reference)
        subbed_string_value = subbed_string_value.gsub(
          "${#{reference}}",
          References.resolve_value(cfn_model, {'Ref'=>reference})
        )
      end
    end
    subbed_string_value
  end

  def self.resolve_if(cfn_model, expression)
    if_expression = expression['Fn::If']
    condition_name = if_expression[0]
    if cfn_model.conditions[condition_name]
      resolve_value(cfn_model, if_expression[1])
    else
      resolve_value(cfn_model, if_expression[2])
    end
  end

  def self.logical_resource_id_from_get_att(attribute_spec, attr_to_retrieve=nil)
    if attribute_spec.is_a? Array
      if !attr_to_retrieve || attribute_spec[1] == attr_to_retrieve
        return attribute_spec.first
      else
        # this could be a reference to a nested stack output so treat it as external
        # and presume the ingress is freestanding.
        return nil
      end
    elsif attribute_spec.is_a? String
      if !attr_to_retrieve || attribute_spec.split('.')[1] == attr_to_retrieve
        return attribute_spec.split('.').first
      else
        # this could be a reference to a nested stack output so treat it as external
        # and presume the ingress is freestanding.
        return nil
      end
    end
  end
end
