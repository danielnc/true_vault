# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'true_vault/version'

Gem::Specification.new do |spec|
  spec.name          = "true_vault"
  spec.version       = TrueVault::VERSION
  spec.authors       = ["Daniel Naves de Carvalho"]
  spec.email         = ["daniel@wearebrane.com"]
  spec.description   = %q{Ruby wrapper for TrueVault}
  spec.summary       = %q{Wrapper for TrueVault}
  spec.homepage      = "https://github.com/danielnc/true_vault"
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_dependency "activemodel"
  spec.add_dependency "hashie"
  spec.add_dependency "faraday"
  spec.add_dependency "faraday_middleware"

  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "minitest", "~> 4.7"
end
