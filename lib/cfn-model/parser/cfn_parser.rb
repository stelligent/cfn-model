# frozen_string_literal: true

require 'yaml'
require 'json'
require 'cfn-model/parser/transform_registry'
require 'cfn-model/validator/cloudformation_validator'
require 'cfn-model/validator/reference_validator'
require_relative 'parser_registry'
require_relative 'parameter_substitution'
require_relative 'parser_error'
Dir["#{__dir__}/../model/*.rb"].each { |model| require "cfn-model/model/#{File.basename(model, '.rb')}" }

##
# This class is the heart of the matter.  It will take a CloudFormation template
# and return a CfnModel object to represent the underlying document in a way
# that is hopefully more convenient for (cfn-nag rule) developers to work with
#
class CfnParser
  # this will convert any !Ref or !GetAtt into tranditional hash like in json
  YAML.add_domain_type('', 'Ref') { |type, val| { 'Ref' => val } }

  YAML.add_domain_type('', 'GetAtt') do |type, val|
    if val.is_a? String
      val = val.split('.')
    end

    { 'Fn::GetAtt' => val }
  end

  %w(Join Base64 Sub Split Select ImportValue GetAZs FindInMap And Or If Not).each do |function_name|
    YAML.add_domain_type('', function_name) { |type, val| { "Fn::#{function_name}" => val } }
  end

  ##
  # Given raw json/yml CloudFormation template, returns a CfnModel object
  # or raise ParserErrors if something is amiss with the format
  def parse(cloudformation_yml, parameter_values_json=nil)
    cfn_model = parse_without_parameters(cloudformation_yml)

    apply_parameter_values(cfn_model, parameter_values_json)

    cfn_model
  end

  def parse_without_parameters(cloudformation_yml)
    pre_validate_model cloudformation_yml

    cfn_hash = YAML.load cloudformation_yml

    # Transform raw resources in template as performed by
    # transforms
    CfnModel::TransformRegistry.instance.perform_transforms cfn_hash

    validate_references cfn_hash

    cfn_model = CfnModel.new
    cfn_model.raw_model = cfn_hash

    # pass 1: wire properties into ModelElement objects
    transform_hash_into_model_elements cfn_hash, cfn_model
    transform_hash_into_parameters cfn_hash, cfn_model

    # pass 2: tie together separate resources only where necessary to make life easier for rule logic
    post_process_resource_model_elements cfn_model

    cfn_model
  end

  private

  def apply_parameter_values(cfn_model, parameter_values_json)
    ParameterSubstitution.new.apply_parameter_values(
      cfn_model,
      parameter_values_json
    )
  end

  def post_process_resource_model_elements(cfn_model)
    cfn_model.resources.each do |_, resource|
      resource_parser_class = ParserRegistry.instance.registry[resource.class.to_s]

      next if resource_parser_class.nil?

      resource_parser = resource_parser_class.new
      resource_parser.parse(cfn_model: cfn_model,
                            resource: resource)
    end
  end

  # pass 0: validate basic syntax so we can make some assumptions down stream
  #         even within the parsing code
  def transform_hash_into_model_elements(cfn_hash, cfn_model)
    cfn_hash['Resources'].each do |resource_name, resource|
      resource_class = class_from_type_name resource['Type']

      resource_object = resource_class.new(cfn_model)
      resource_object.logical_resource_id = resource_name
      resource_object.resource_type = resource['Type']
      resource_object.metadata = resource['Metadata']

      assign_fields_based_upon_properties resource_object, resource

      cfn_model.resources[resource_name] = resource_object
    end
    cfn_model
  end

  def transform_hash_into_parameters(cfn_hash, cfn_model)
    return cfn_model unless cfn_hash.has_key?('Parameters')

    cfn_hash['Parameters'].each do |parameter_name, parameter_hash|
      parameter = Parameter.new
      parameter.id = parameter_name
      parameter.type = parameter_hash['Type']

      parameter_hash.each do |property_name, property_value|
        next if %w(Type).include? property_name
        parameter.send("#{map_property_name_to_attribute(property_name)}=", property_value)
      end

      cfn_model.parameters[parameter_name] = parameter
    end
    cfn_model
  end

  def pre_validate_model(cloudformation_yml)
    errors = CloudFormationValidator.new.validate cloudformation_yml
    if !errors.nil? && !errors.empty?
      raise ParserError.new('Basic CloudFormation syntax error', errors)
    end
  end

  def validate_references(cfn_hash)
    unresolved_refs = ReferenceValidator.new.unresolved_references(cfn_hash)
    unless unresolved_refs.empty?
      raise ParserError.new("Unresolved logical resource ids: #{unresolved_refs.to_a}")
    end
  end

  def assign_fields_based_upon_properties(resource_object, resource)
    unless resource['Properties'].nil?
      resource['Properties'].each do |property_name, property_value|
        resource_object.send("#{map_property_name_to_attribute(property_name)}=", property_value)
      end
    end
  end

  def class_from_type_name(type_name)
    begin
      resource_class = Object.const_get type_name, inherit=false
    rescue NameError
      # puts "Never seen class: #{type_name} so going dynamic"
      resource_class = generate_resource_class_from_type type_name
    end
    resource_class
  end

  def map_property_name_to_attribute(str)
    (str.slice(0).downcase + str[1..(str.length)]).gsub /-/, '_'
  end

  def generate_resource_class_from_type(type_name)
    resource_class = Class.new(ModelElement)

    module_names = type_name.split('::')
    if module_names.first == 'Custom'
      custom_resource_class_name = initial_upper(module_names[1])
      begin
        resource_class = Object.const_get custom_resource_class_name
      rescue NameError
        Object.const_set(custom_resource_class_name, resource_class)
      end
    elsif module_names.first == 'AWS'
      begin
        module_constant = AWS.const_get(module_names[1])
      rescue NameError
        module_constant = Module.new
        module_constant.const_set(module_names[1], module_constant)
      end
      module_constant.const_set(module_names[2], resource_class)
    else
      raise "Unknown namespace in resource type: #{module_names.first}"
    end
    resource_class
  end

  def initial_upper(str)
    str.slice(0).upcase + str[1..(str.length)]
  end
end
