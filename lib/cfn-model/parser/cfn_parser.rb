require 'yaml'
require 'cfn-model/validator/cloudformation_validator'
require 'cfn-model/validator/reference_validator'
require_relative 'parser_registry'
require_relative 'parser_error'
Dir["#{__dir__}/../model/*.rb"].each { |model| require "cfn-model/model/#{File.basename(model, '.rb')}" }

##
# This class is the heart of the matter.  It will take a CloudFormation template
# and return a CfnModel object to represent the underlying document in a way
# that is hopefully more convenient for (cfn-nag rule) developers to work with
#
class CfnParser
  # this will convert any !Ref or !GetAtt into tranditional hash like in json
  YAML.add_domain_type('', 'GetAtt') { |type, val| { 'Fn::GetAtt' => val } }
  YAML.add_domain_type('', 'Ref') { |type, val| { 'Ref' => val } }

  ##
  # Given raw json/yml CloudFormation template, returns a CfnModel object
  # or raise ParserErrors if something is amiss with the format
  def parse(cloudformation_yml)
    cfn_hash = pre_validate_model cloudformation_yml

    cfn_model = CfnModel.new
    cfn_model.raw_model = cfn_hash

    # pass 1: wire properties into ModelElement objects
    transform_hash_into_model_elements cfn_hash, cfn_model

    # pass 2: tie together separate resources only where necessary to make life easier for rule logic
    post_process_resource_model_elements cfn_model

    cfn_model
  end

  private

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

      resource_object = resource_class.new
      resource_object.logical_resource_id = resource_name
      resource_object.resource_type = resource['Type']

      assign_fields_based_upon_properties resource_object, resource

      cfn_model.resources[resource_name] = resource_object
    end
    cfn_model
  end

  def pre_validate_model(cloudformation_yml)
    errors = CloudFormationValidator.new.validate cloudformation_yml
    if !errors.nil? && !errors.empty?
      raise ParserError.new('Basic CloudFormation syntax error', errors)
    end

    cfn_hash = YAML.load cloudformation_yml

    unresolved_refs = ReferenceValidator.new.unresolved_references(cfn_hash)
    unless unresolved_refs.empty?
      raise ParserError.new("Unresolved logical resource ids: #{unresolved_refs.to_a}")
    end
    cfn_hash
  end

  def assign_fields_based_upon_properties(resource_object, resource)
    unless resource['Properties'].nil?
      resource['Properties'].each do |property_name, property_value|
        resource_object.send("#{initialLower(property_name)}=", property_value)
      end
    end
  end

  def class_from_type_name(type_name)
    begin
      resource_class = Object.const_get type_name, inherit=false
    rescue NameError
      puts "Never seen class: #{type_name} so going dynamic"
      resource_class = Class.new(DynamicModelElement)

      begin
        module_constant = AWS.const_get(type_name.split('::')[1])
      rescue NameError
        module_constant = Module.new
        module_constant.const_set(type_name.split('::')[1], module_constant)
      end

      module_constant.const_set(type_name.split('::')[2], resource_class)
    end
    resource_class
  end

  def initialLower(str)
    str.slice(0).downcase + str[1..(str.length)]
  end
end
