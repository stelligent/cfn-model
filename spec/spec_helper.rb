require 'simplecov'
SimpleCov.start do
  add_filter 'spec/'
end


require 'factories/security_group'
require 'json'
require 'yaml'

YAML.add_domain_type('', 'GetAtt') { |type, val| { 'Fn::GetAtt' => val } }
YAML.add_domain_type('', 'Ref') { |type, val| { 'Ref' => val } }

def direct_json_model(test_file:)
  YAML.load(IO.read("spec/test_templates/json/#{test_file}"))
end

# surprise suprise - JSON is a proper subset of YAML 1.2 and higher????
def direct_yaml_model(test_file:)
  x = YAML.load(IO.read("spec/test_templates/yaml/#{test_file}"))
  puts x
  x
end

