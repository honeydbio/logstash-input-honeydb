Gem::Specification.new do |s|
  s.name          = 'logstash-input-honeydb'
  s.version       = '0.1.1'
  s.licenses      = ['Apache-2.0']
  s.summary       = 'Logstash input plugin for HoneyDB.'
  s.description   = 'Logstash input plugin for the HoneyDB Threat Information API https://honeydb.io/threats'
  s.homepage      = 'https://github.com/honeydbio'
  s.authors       = ['foospidy']
  s.email         = 'foospidy@users.noreply.github.com'
  s.require_paths = ['lib']

  # Files
  s.files = Dir['lib/**/*','spec/**/*','vendor/**/*','*.gemspec','*.md','CONTRIBUTORS','Gemfile','LICENSE','NOTICE.TXT']
   # Tests
  s.test_files = s.files.grep(%r{^(test|spec|features)/})

  # Special flag to let us know this is actually a logstash plugin
  s.metadata = { "logstash_plugin" => "true", "logstash_group" => "input" }

  # Gem dependencies
  s.add_runtime_dependency "logstash-core-plugin-api", "~> 2.0"
  s.add_runtime_dependency 'stud', '~> 0.0', '>= 0.0.22'
  s.add_development_dependency 'logstash-devutils', '~> 0.0', '>= 0.0.16'
end
