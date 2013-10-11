# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'pmp/version'

Gem::Specification.new do |gem|
  gem.name          = 'pmp'
  gem.version       = PMP::VERSION
  gem.authors       = ['Andrew Kuklewicz']
  gem.email         = ['andrew@prx.org']
  gem.description   = %q{Public Media Platform Ruby Gem}
  gem.summary       = %q{Public Media Platform Ruby Gem}
  gem.homepage      = ''
  gem.license       = 'MIT'

  gem.files         = `git ls-files`.split($/)
  gem.executables   = gem.files.grep(%r{^bin/}) { |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ['lib']

  gem.add_development_dependency('bundler', '~> 1.3')
  gem.add_development_dependency('rake')
  gem.add_development_dependency('rake')
  gem.add_development_dependency('minitest')
  gem.add_development_dependency('webmock')
  gem.add_development_dependency('pry')
  gem.add_development_dependency('guard')
  gem.add_development_dependency('guard-bundler')
  gem.add_development_dependency('guard-minitest')

  gem.add_runtime_dependency('faraday')
  gem.add_runtime_dependency('faraday_middleware')
  gem.add_runtime_dependency('oauth2')
  gem.add_runtime_dependency('multi_json')
  gem.add_runtime_dependency('excon')
  gem.add_runtime_dependency('hashie')
  gem.add_runtime_dependency('activesupport')
  gem.add_runtime_dependency('uri_template')

end
