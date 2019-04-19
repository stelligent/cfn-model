# frozen_string_literal: true

require_relative 'resource_type_validator'
require 'yaml'

##
# This generator is a bit of hacking to trick kwalify into validating yaml for a cfn template.
#
# because cfn uses open-ended key names for the resources.... a static schema can't be used
# with kwalify.  so first we make sure there is a basic structure of resources with Type values
# then we generate the schema from the document for the keys and cross-reference with schema
# files per resource type
class SchemaGenerator
  def generate(cloudformation_yml)

    # make sure structure of Resources is decent and that every record has a Type at least
    cloudformation_hash = ResourceTypeValidator.validate cloudformation_yml

    parameters_schema = generate_schema_for_parameter_keys cloudformation_hash
    resources_schema = generate_schema_for_resource_keys cloudformation_hash

    main_schema = YAML.load IO.read(schema_file('schema.yml.erb'))
    if parameters_schema.empty?
      main_schema['mapping'].delete 'Parameters'
    else
      main_schema['mapping']['Parameters']['mapping'] = parameters_schema
    end
    main_schema['mapping']['Resources']['mapping'] = resources_schema
    main_schema
  end

  private

  ##
  # this is fairly superfluous.  there's not much structure here
  # except that Types are Strings.... anything else is up to a rule
  # to wade through all the optional crap (like looking for NoEcho)
  def generate_schema_for_parameter_keys(cloudformation_hash)
    return {} if cloudformation_hash['Parameters'].nil?

    parameters_schema = {
      '=' => { 'type' => 'any'}
    }

    cloudformation_hash['Parameters'].each do |parameter_key, parameter|
      parameters_schema[parameter_key] = {
        'type' => 'map',
        'mapping' => {
          'Type' => {
            'type' => 'str'
          },
          '=' => {
            'type' => 'any'
          }
        }
      }
    end
    parameters_schema
  end

  def generate_schema_for_resource_keys(cloudformation_hash)
    resources_schema = {
      '=' => { 'type' => 'any'}
    }

    cloudformation_hash['Resources'].each do |resource_id, resource|
      schema_hash = schema_for_type(resource['Type'])
      unless schema_hash.nil?
        resources_schema[resource_id] = schema_hash
      end
    end
    resources_schema
  end

  def schema_file(file)
    "#{__dir__}/../schema/#{file.gsub(/::/, '_')}"
  end

  def schema_for_type(type)
    schema_file_path = schema_file("#{type}.yml")

    if !File.exist? schema_file_path
      nil
    else
      YAML.load IO.read(schema_file_path)
    end
  end
end