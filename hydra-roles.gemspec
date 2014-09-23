# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'hydra/roles/version'

Gem::Specification.new do |spec|
  spec.name          = "hydra-roles"
  spec.version       = Hydra::Roles::VERSION
  spec.authors       = ["David Chandek-Stark"]
  spec.email         = ["dchandekstark@gmail.com"]
  spec.summary       = %q{Role-based authorization for Hydra.}
  spec.description   = %q{Role-based authorization for Hydra.}
  spec.homepage      = "https://github.com/duke-libraries/hydra-roles"
  spec.license       = "APACHE2"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_dependency "hydra-validations"
  spec.add_dependency "active-fedora", "~> 7.1"
  spec.add_development_dependency "bundler", "~> 1.6"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "rspec", "~> 3.1"
end
