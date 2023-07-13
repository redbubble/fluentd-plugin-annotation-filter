# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

Gem::Specification.new do |gem|
  gem.name          = "fluent-plugin-annotation-filter"
  gem.version       = ENV["VERSION"]
  gem.authors       = ["Delivery Engineering"]
  gem.email         = ["delivery-engineers@redbubble.com"]
  gem.description   = %q{Fluent plugin to filter based on Kubernetes annotations}
  gem.summary       = %q{A filter plugin to drop log entries without the right set of Kubernetes annotations}
  gem.homepage      = "https://github.com/redbubble/fluent-plugin-annotation-filter"
  gem.license       = "MIT"

  gem.files = Dir['lib/**/*'] + %w(Gemfile README.md fluent-plugin-annotation-filter.gemspec)
  gem.executables   = gem.files.grep(%r{^bin/}) { |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ["lib"]

  gem.required_ruby_version = '>= 3.1.2'

  gem.add_runtime_dependency "fluentd", '~> 1.16.1', '>= 1.16.1'

  gem.add_development_dependency "bundler", "~> 2.3"
  gem.add_development_dependency "rspec", "~> 3.11"     # Like all our other Ruby projects, our tests are in RSpec
  gem.add_development_dependency "test-unit", "~> 3.5" # TestUnit is, however, used by fluentd's test driver and must be included
end
