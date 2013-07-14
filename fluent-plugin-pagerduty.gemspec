# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'fluent/plugin/pagerduty/version'

Gem::Specification.new do |spec|
  spec.name          = "fluent-plugin-pagerduty"
  spec.version       = Fluent::Plugin::Pagerduty::VERSION
  spec.authors       = ["Kentaro Yoshida"]
  spec.email         = ["y.ken.studio@gmail.com"]
  spec.description   = %q{Fluentd Input plugin to call PagerDuty API.}
  spec.summary       = %q{Fluentd Input plugin to call PagerDuty API.}
  spec.homepage      = "https://github.com/y-ken/fluent-plugin-pagerduty"
  spec.license       = "Apache License, Version 2.0"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake"
  spec.add_runtime_dependency "fluentd"
  spec.add_runtime_dependency "pagerduty"
end
