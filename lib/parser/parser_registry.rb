require_relative 'security_group_parser'
require_relative 'iam_user_parser'
require_relative 'parser_registry'

class ParserRegistry
  attr_reader :registry

  def initialize
    @registry = {
      'AWS::EC2::SecurityGroup' => SecurityGroupParser,
      'AWS::IAM::User' => IamUserParser
    }
  end

  def self.instance
    if @instance.nil?
      @instance = ParserRegistry.new
    end
    @instance
  end

  def add_parser(resource_name, parser)
    @registry[resource_name] = parser
  end

end