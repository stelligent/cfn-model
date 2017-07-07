require 'validator/cloudformation_validator'
require 'validator/reference_validator'
require 'model/cfn_model'
require 'yaml'
require_relative 'parser_registry'
require_relative 'parser_error'
require 'model/iam_user'
require 'model/security_group'
require 'model/security_group_egress'
require 'model/security_group_ingress'
require 'model/iam_group'


class CfnParser
  YAML.add_domain_type('', 'GetAtt') { |type, val| { 'Fn::GetAtt' => val } }
  YAML.add_domain_type('', 'Ref') { |type, val| { 'Ref' => val } }

  def parse(cloudformation_yml)

    # pass 0: validate basic syntax so we can make some assumptions down stream
    #         even within the parsing code
    errors = CloudFormationValidator.new.validate cloudformation_yml
    puts "Error: #{errors}"
    if !errors.nil? && !errors.empty?
      raise ParserError.new('Basic CloudFormation syntax error', errors)
    end

    cfn_hash = YAML.load cloudformation_yml

    unresolved_refs = ReferenceValidator.new.unresolved_references(cfn_hash)
    unless unresolved_refs.empty?
      raise ParserError.new("Unresolved logical resource ids: #{unresolved_refs.to_a}")
    end

    cfn_model = CfnModel.new
    cfn_model.raw_model = cfn_hash

      # pass 1: wire properties into ModelElement objects
    cfn_hash['Resources'].each do |resource_name, resource|
      begin
        resource_class = Object.const_get resource['Type']
      rescue NameError
        # some resource we've never seen so chill
        resource_class = nil
      end

      next if resource_class.nil?

      resource_object = resource_class.new
      resource_object.logical_resource_id = resource_name
      resource_object.resource_type = resource['Type']

      unless resource['Properties'].nil?
        resource['Properties'].each do |property_name, property_value|
          resource_object.send("#{initialLower(property_name)}=", property_value)
        end
      end

      cfn_model.resources[resource_name] = resource_object
    end

    # pass 2: tie together separate resources only where necessary to make life easier for rule logic
    cfn_model.resources.each do |resource_name, resource|
      resource_parser_class = ParserRegistry.instance.registry[resource.class.to_s]

      next if resource_parser_class.nil?

      resource_parser = resource_parser_class.new
      resource_parser.parse(cfn_model: cfn_model,
                            resource: resource)
    end

    cfn_model
  end

  private

  def initialLower(str)
    str.slice(0).downcase + str[1..(str.length)]
  end
end
