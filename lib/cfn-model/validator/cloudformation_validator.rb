require_relative 'schema_generator'
require 'kwalify'

class CloudFormationValidator
  def validate(cloudformation_string)
    schema = SchemaGenerator.new.generate cloudformation_string

    validator = Kwalify::Validator.new(schema)

    validator.validate(YAML.load(cloudformation_string))
  end
end
