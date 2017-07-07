require 'simplecov'
SimpleCov.start do
  add_filter 'spec/'
end

require 'model/model_element'
include AWS::IAM
include AWS::EC2

require 'factories/security_group'
require 'factories/iam_user'
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
