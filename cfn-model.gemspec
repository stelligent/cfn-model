require 'rake'

Gem::Specification.new do |s|
  s.name          = 'cfn-model'
  s.license       = 'MIT'
  s.version       = '0.0.0'
  s.bindir        = 'bin'
  s.authors       = %w(someguy)
  s.summary       = 'cfn-model'
  s.description   = 'An object model for CloudFormation templates'
  s.homepage      = 'https://github.com/stelligent/cfn-model'
  s.files         = FileList[ 'lib/**/*.rb', 'lib/**/*.yml', 'lib/**/*.erb']

  s.require_paths << 'lib'

  s.required_ruby_version = '~> 2.2'

  s.add_runtime_dependency('kwalify', '0.7.2')
end