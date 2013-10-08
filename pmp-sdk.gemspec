# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'pmp/version'

Gem::Specification.new do |spec|
  spec.name          = "pmp-sdk"
  spec.version       = PMP::VERSION
  spec.authors       = ["Andrew Kuklewicz"]
  spec.email         = ["andrew@prx.org"]
  spec.description   = %q{Public Media Platform Ruby SDK}
  spec.summary       = %q{Public Media Platform Ruby SDK}
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake"
  spec.add_runtime_dependency "roar"
end
