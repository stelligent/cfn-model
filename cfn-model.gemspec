require 'rake'

Gem::Specification.new do |s|
  s.name          = 'cfn-model'
  s.license       = 'MIT'
  s.version       = '9.9.9'
  s.executables   = %w(cfn_parse)
  s.authors       = ['Eric Kascic']
  s.summary       = 'cfn-model'
  s.description   = 'An object model for CloudFormation templates'
  s.homepage      = 'https://github.com/stelligent/cfn-model'
  s.files         = FileList[ 'lib/**/*.rb', 'lib/**/*.yml', 'lib/**/*.erb']

  s.require_paths << 'lib'

  s.required_ruby_version = '>= 2.5.0'

  s.add_development_dependency 'rubocop'

  s.add_runtime_dependency('kwalify', '0.7.2')
  s.add_runtime_dependency('psych', '~> 3')
end
