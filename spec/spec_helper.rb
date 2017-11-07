require 'simplecov'
SimpleCov.start do
  add_filter 'spec/'
end

require 'cfn-model/model/model_element'

require 'factories/security_group'
require 'factories/iam_user'
require 'factories/iam_user'
Dir["#{__dir__}/factories/*.rb"].each { |model| require "factories/#{File.basename(model, '.rb')}" }

require 'json'
require 'yaml'

def test_templates(name)
  %W(
    spec/test_templates/json/#{name}.json
    spec/test_templates/yaml/#{name}.yml
  )
end

def yaml_test_templates(name)
  %W(
    spec/test_templates/yaml/#{name}.yml
  )
end

def json_test_templates(name)
  %W(
    spec/test_templates/json/#{name}.json
  )
end