# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'dynamics_crm/version'

Gem::Specification.new do |spec|
  spec.name          = "dynamics_crm"
  spec.version       = DynamicsCRM::VERSION
  spec.authors       = ["Joe Heth"]
  spec.email         = ["joeheth@gmail.com"]
  spec.description   = %q{Ruby API for integrating with MS Dynamics 2011/2013 SOAP API}
  spec.summary       = %q{Ruby gem for integrating with MS Dynamics 2011/2013 SOAP API}
  spec.homepage      = "https://github.com/TinderBox/dynamics_crm"
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_runtime_dependency 'curb', '~> 0.8', '>= 0.8.5'
  spec.add_runtime_dependency 'mimemagic', '~> 0.2', '>= 0.2.1'
  spec.add_runtime_dependency 'builder', '>= 3.0.0', '< 4.0.0'

  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency 'rake', '~> 10.1'
  spec.add_development_dependency 'rspec', '~> 2.14'
  spec.add_development_dependency 'simplecov', '~> 0.7'
  spec.add_development_dependency 'pry', '~> 0.10.3'
end
