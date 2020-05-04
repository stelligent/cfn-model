# frozen_string_literal: true

require 'cfn-model/parser/parser_error'

##
# this is a placeholder for anything related to resolving references
#
# not sure if we are going to be able to have a useful generic set of code for
# references yet... in the meantime pile things up here and hope a pattern becomes
# clear
module References
  def self.resolve_value(cfn_model, value)
    if value.is_a? Hash
      if value.has_key?('Ref')
        resolve_reference(cfn_model, value)
      elsif value.has_key?('Fn::FindInMap')
        resolve_map(cfn_model, value)
      elsif value.has_key?('Fn::If')
        resolve_if(cfn_model, value)
      else
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
