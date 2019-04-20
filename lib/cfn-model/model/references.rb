# frozen_string_literal: true

##
# this is a placeholder for anything related to resolving references
#
# not sure if we are going to be able to have a useful generic set of code for
# references yet... in the meantime pile things up here and hope a pattern becomes
# clear
module References
  def self.resolve_value(cfn_model, value)
    if value.is_a? Hash
      if value.key?('Ref')
        ref_id = value['Ref']
        if ref_id.is_a? String
          if cfn_model.parameters.key?(ref_id)
            return value if cfn_model.parameters[ref_id].synthesized_value.nil?
            cfn_model.parameters[ref_id].synthesized_value
          else
            value
          end
        else
          value
        end
      else
        value
      end
    else
      value
    end
  end

  def self.security_group_id_external?(group_id)
    resolve_security_group_id(group_id).nil?
  end

  ##
  # Return nil if
  def self.resolve_security_group_id(group_id)
    return nil if group_id.is_a? String

    # an imported value can only yield a literal to an external sg vs. referencing something local
    if !group_id['Ref'].nil?
      group_id['Ref']
    elsif !group_id['Fn::GetAtt'].nil?
      logical_resource_id_from_get_att group_id['Fn::GetAtt']
    else # !group_id['Fn::ImportValue'].nil?
      # anything else will be string manipulation functions
      # which again leads us back to a string which must be an external security group known out of band
      # so don't/can't link it up to a security group
      nil
    end
  end

  private_class_method def self.logical_resource_id_from_get_att(attribute_spec)
    if attribute_spec.is_a? Array
      if attribute_spec[1] == 'GroupId'
        attribute_spec.first
      else
        # this could be a reference to a nested stack output so treat it as external
        # and presume the ingress is freestanding.
        nil
      end
    elsif attribute_spec.is_a? String
      if attribute_spec.split('.')[1] == 'GroupId'
        attribute_spec.split('.').first
      else
        # this could be a reference to a nested stack output so treat it as external
        # and presume the ingress is freestanding.
        nil
      end
    end
  end
end
