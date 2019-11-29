# frozen_string_literal: true

require 'set'

class ReferenceValidator
  def unresolved_references(cloudformation_hash)
    if cloudformation_hash['Parameters'].nil?
      parameter_keys = []
    else
      parameter_keys = cloudformation_hash['Parameters'].keys
    end

    resource_keys = cloudformation_hash['Resources'].keys

    legal_identifiers = Set.new(parameter_keys + resource_keys)
    missing_refs = all_references(cloudformation_hash) - legal_identifiers
    post_process_special_refs(missing_refs, legal_identifiers)
  end

  private

  SPECIAL_REF_REGEXP = /(.+)\..+/

  def post_process_special_refs(missing_refs, legal_identifiers)
    missing_refs.delete_if do |missing_ref|
      match_data = missing_ref.match SPECIAL_REF_REGEXP
      if match_data
        resource_id = match_data[1]
        legal_identifiers.member?(resource_id)
      end
    end
  end

  def all_references(cloudformation_hash)
    result = Set.new
    cloudformation_hash['Resources'].values.each do |resource_hash|
      result |= all_ref(resource_hash['Properties'])
      result |= all_get_att(resource_hash['Properties'])
    end
    result
  end

  def all_ref(properties_hash)
    refs = Set.new

    unless properties_hash.nil?
      properties_hash.values.each do |value|
        if value.is_a? Hash
          sub_hash = value

          if sub_hash.size == 1 && !sub_hash['Ref'].nil?
            unless sub_hash['Ref'].is_a? String
              raise ParserError.new("Ref target must be string literal: #{sub_hash}")
            end

            unless pseudo_reference?(sub_hash['Ref'])
              refs << sub_hash['Ref']
            end
          else
            refs |= all_ref(sub_hash)
          end
        end
      end
    end
    refs
  end

  def all_get_att(properties_hash)
    refs = Set.new

    unless properties_hash.nil?
      properties_hash.values.each do |value|
        if value.is_a? Hash
          sub_hash = value

          # ! GetAtt too
          if sub_hash.size == 1 && !sub_hash['Fn::GetAtt'].nil?
            if sub_hash['Fn::GetAtt'].is_a? Array
              refs << sub_hash['Fn::GetAtt'][0]
            elsif sub_hash['Fn::GetAtt'].is_a? String
              if sub_hash['Fn::GetAtt'] =~ /([^.]*)\.(.*)/
                refs << $1
              end

            end
          else
            refs |= all_get_att(sub_hash)
          end
        end
      end
    end

    refs
  end

  def pseudo_reference?(ref)
    ref =~ /AWS::.*/
  end
end
