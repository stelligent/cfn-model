Dir["#{__dir__}/../transforms/*.rb"].each do |transform|
  require "cfn-model/transforms/#{File.basename(transform, '.rb')}"
end

class CfnModel
  # TransformRegistry provides a registry of CloudFormation transforms
  # available for templates
  class TransformRegistry
    attr_reader :registry

    def initialize
      @registry = {
        'AWS::Serverless-2016-10-31' => CfnModel::Transforms::Serverless
      }
    end

    def perform_transforms(cfn_hash)
      transform_name = cfn_hash['Transform']
      return unless transform_name
      @registry[transform_name].instance.perform_transform cfn_hash
    end

    def self.instance
      @instance ||= TransformRegistry.new
      @instance
    end
  end
end

class CfnModel
  class Transforms
  end
end
