# frozen_string_literal: true

require 'yaml'
require 'psych'
require 'json'
require 'cfn-model/parser/transform_registry'
require 'cfn-model/validator/cloudformation_validator'
require 'cfn-model/validator/reference_validator'
require 'cfn-model/psych/handlers/line_number_handler'
require 'cfn-model/psych/visitors/to_ruby_with_line_numbers'
require 'cfn-model/monkey_patches/psych/nodes/node'
require_relative 'parser_registry'
require_relative 'parameter_substitution'
require_relative 'parser_error'
require_relative 'expression_evaluator'
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
  def parse(cloudformation_yml, parameter_values_json=nil, with_line_numbers=false, condition_values_json=nil)
    cfn_model = parse_without_parameters(cloudformation_yml, with_line_numbers, condition_values_json)

    apply_parameter_values(cfn_model, parameter_values_json)

    # pass 2: tie together separate resources only where necessary to make life easier for rule logic
    post_process_resource_model_elements cfn_model

    cfn_model
  end

  def parse_with_line_numbers(cloudformation_yml)
    handler = LineNumberHandler.new
    parser =  Psych::Parser.new(handler)
    handler.parser = parser
    parser.parse(cloudformation_yml)
    ToRubyWithLineNumbers.create.accept(handler.root).first
  end

  def parse_without_parameters(cloudformation_yml, with_line_numbers=false, condition_values_json=nil)
    pre_validate_model cloudformation_yml

    cfn_hash =
      if with_line_numbers
        parse_with_line_numbers(cloudformation_yml)
      else
        YAML.load cloudformation_yml
      end

    # Transform raw resources in template as performed by
    # transforms
    CfnModel::TransformRegistry.instance.perform_transforms cfn_hash

    validate_references cfn_hash

    cfn_model = CfnModel.new
    cfn_model.raw_model = cfn_hash

    process_conditions cfn_hash, cfn_model, condition_values_json

    process_mappings cfn_hash, cfn_model

    # pass 1: wire properties into ModelElement objects
    if with_line_numbers
      transform_hash_into_model_elements_with_numbers cfn_hash, cfn_model
    else
      transform_hash_into_model_elements cfn_hash, cfn_model
    end
    transform_hash_into_parameters cfn_hash, cfn_model
    transform_hash_into_globals cfn_hash, cfn_model



    cfn_model
  end

  private

  def process_mappings(cfn_hash, cfn_model)
    if cfn_hash.key?('Mappings')
      cfn_hash['Mappings'].each do |mapping_key, mapping_value|
        cfn_model.mappings[mapping_key] = mapping_value
      end
    end
  end

  def process_conditions(cfn_hash, cfn_model, condition_values_json)
    if cfn_hash.key?('Conditions')
      if condition_values_json.nil?
        condition_values = {}
      else
        condition_values = JSON.load condition_values_json
      end

      cfn_hash['Conditions'].each do |condition_key, _|
        if condition_values.key?(condition_key) && [true, false].include?(condition_values[condition_key])
          cfn_model.conditions[condition_key] = condition_values[condition_key]
        else
          cfn_model.conditions[condition_key] = true
        end
      end
    end
  end

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

      assign_fields_based_upon_properties resource_object, resource, cfn_model

      cfn_model.resources[resource_name] = resource_object
      cfn_model.element_types[resource_name] = "resource"
    end
    cfn_model
  end

  def transform_hash_into_model_elements_with_numbers(cfn_hash, cfn_model)
    cfn_hash['Resources'].each do |resource_name, resource|
      resource_class = class_from_type_name resource['Type']['value']

      resource_object = resource_class.new(cfn_model)
      resource_object.logical_resource_id = resource_name
      resource_object.resource_type = resource['Type']['value']
      resource_object.metadata = resource['Metadata']

      assign_fields_based_upon_properties resource_object, resource, cfn_model

      cfn_model.resources[resource_name] = resource_object
      cfn_model.line_numbers[resource_name] = resource['Type']['line']
      cfn_model.element_types[resource_name] = "resource"
    end
    cfn_model
  end

  def transform_hash_into_parameters(cfn_hash, cfn_model)
    return cfn_model unless cfn_hash.key?('Parameters')

    cfn_hash['Parameters'].each do |parameter_name, parameter_hash|
      parameter = Parameter.new
      parameter.id = parameter_name
      parameter.type = parameter_hash['Type']
      parameter.logical_resource_id = parameter_name

      parameter_hash.each do |property_name, property_value|
        next if %w(Type).include? property_name
        parameter.send("#{map_property_name_to_attribute(property_name)}=", property_value)
      end

      cfn_model.parameters[parameter_name] = parameter
      cfn_model.line_numbers[parameter_name] = parameter_hash['Type']['line']
      cfn_model.element_types[parameter_name] = "parameter"
    end
    cfn_model
  end

  def transform_hash_into_globals(cfn_hash, cfn_model)
    return cfn_model unless cfn_hash.key?('Globals')

    cfn_hash['Globals'].each do |resource, parameter_hash|
      global = Parameter.new
      global.id = resource

      parameter_hash.each do |property_name, property_value|
        global.send("#{map_property_name_to_attribute(property_name)}=", property_value)
      end

      cfn_model.globals[resource] = global
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

  def deal_with_conditional_property_definitions(resource, cfn_model)
    all_extra_concrete_properties = []
    resource['Properties'].each do |property_name, property_value|
      next if %w(Fn::Transform).include? property_name
      if property_name == 'Fn::If'
        concrete_properties = ExpressionEvaluator.new.evaluate(
          {'Fn::If'=>property_value},
          cfn_model.conditions
        )
        all_extra_concrete_properties << concrete_properties
      end
    end
    all_extra_concrete_properties.each do |extra_concrete_properties|
      resource['Properties'].merge!(extra_concrete_properties)
    end
    resource['Properties'].delete('Fn::If')
  end

  def assign_fields_based_upon_properties(resource_object, resource, cfn_model)
    unless resource['Properties'].nil?
      deal_with_conditional_property_definitions(resource, cfn_model)

      resource['Properties'].each do |property_name, property_value|
        next if %w(Fn::Transform).include? property_name
        resource_object.send("#{map_property_name_to_attribute(property_name)}=", map_property_value(property_value, cfn_model))
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

  def map_property_value(property_value, cfn_model)
    ExpressionEvaluator.new.evaluate(property_value, cfn_model.conditions)
  end

  def map_property_name_to_attribute(str)
    (str.slice(0).downcase + str[1..(str.length)]).gsub /-/, '_'
  end

  ##
  # strip any characters that are legal in a resource name that
  # are going to make for a legal character in a ruby class name
  def clean_module_name(module_name)
    module_name.gsub /[\-@]/, ''
  end

  def map_non_aws_resource_name_to_class_name(module_names)
    # this is a little hacky.  we've been ignoring Custom so more for
    # backward compat. for Alexa and other transformed resources just jam the whole
    # thing together
    if module_names.first == 'Custom'
      first_module_index = 1
    else
      first_module_index = 0
    end
    module_names[first_module_index..-1].reduce('') do |class_name, module_name|
      class_name + initial_upper(clean_module_name(module_name))
    end
  end

  def generate_resource_class_from_type(type_name)
    resource_class = Class.new(ModelElement)

    module_names = type_name.split('::')
    if module_names.first == 'AWS'
      begin
        module_constant = AWS.const_get(module_names[1])
      rescue NameError
        module_constant = Module.new
        module_constant.const_set(module_names[1], module_constant)
      end
      module_constant.const_set(module_names[2], resource_class)
    else
      custom_resource_class_name = map_non_aws_resource_name_to_class_name(module_names)
      begin
        custom_class = Object.const_get custom_resource_class_name
        resource_class = custom_class if custom_class.is_a?(ModelElement)
      rescue NameError
        Object.const_set(custom_resource_class_name, resource_class)
      end
    end
    resource_class
  end

  def initial_upper(str)
    str.slice(0).upcase + str[1..(str.length)]
  end
end
