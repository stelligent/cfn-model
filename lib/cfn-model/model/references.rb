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
        ref_id = value['Ref']
        if ref_id.is_a? String
          if cfn_model.parameters.has_key?(ref_id)
            return value if cfn_model.parameters[ref_id].synthesized_value.nil?
            return cfn_model.parameters[ref_id].synthesized_value
          else
            return value
          end
        else
          return value
        end
      else
        return value
      end
    else
      return value
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

  private

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
