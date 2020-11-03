# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

Gem::Specification.new do |gem|
  gem.name          = "fluentd-plugin-annotation-filter"
  gem.version       = "1.0.0"
  gem.authors       = ["Delivery Engineering"]
  gem.email         = ["delivery-engineers@redbubble.com"]
  gem.description   = %q{Fluentd plugin to filter based on Kubernetes annotations}
  gem.summary       = %q{A filter plugin to drop log entries without the right set of Kubernetes annotations}
  gem.homepage      = "https://github.com/redbubble/fluentd-plugin-annotation-filter"
  gem.license       = "All Rights Reserved"

  gem.files = Dir['lib/**/*'] + %w(Gemfile README.md fluentd-plugin-annotation-filter.gemspec)
  gem.executables   = gem.files.grep(%r{^bin/}) { |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ["lib"]

  gem.required_ruby_version = '>= 2.5.0'

  gem.add_runtime_dependency "fluentd", '~> 1.3.3', '>= 1.3.3'

  gem.add_development_dependency "bundler", "~> 1.3"
  gem.add_development_dependency "rspec", "~> 3.0"     # Like all our other Ruby projects, our tests are in RSpec
  gem.add_development_dependency "test-unit", "~> 3.3" # TestUnit is, however, used by fluentd's test driver and must be included
end
