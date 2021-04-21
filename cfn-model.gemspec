Gem::Specification.new do |s|
  s.name          = 'cfn-model'
  s.license       = 'MIT'
  s.version       = '9.9.9'
  s.executables   = %w(cfn_parse)
  s.authors       = ['Eric Kascic']
  s.summary       = 'cfn-model'
  s.description   = 'An object model for CloudFormation templates'
  s.homepage      = 'https://github.com/stelligent/cfn-model'
  s.metadata      = {
    'bug_tracker_uri'   => "#{s.homepage}/issues",
    'changelog_uri'     => "#{s.homepage}/releases",
    'documentation_uri' => "https://www.rubydoc.info/gems/#{s.name}/#{s.version}",
    'homepage_uri'      => s.homepage,
    'source_code_uri'   => "#{s.homepage}/tree/v#{s.version}",
  }
  s.files         = Dir.glob([ 'lib/**/*.rb', 'lib/**/*.yml', 'lib/**/*.erb'])

  s.require_paths << 'lib'

  s.required_ruby_version = '>= 2.5.0'

  s.add_development_dependency('rake')
  s.add_development_dependency('rspec', '~> 3.4')
  s.add_development_dependency('rubocop')
  s.add_development_dependency('simplecov', '~> 0.11')

  s.add_runtime_dependency('kwalify', '0.7.2')
  s.add_runtime_dependency('psych', '~> 3')
end
