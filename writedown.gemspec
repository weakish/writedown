# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'writedown/version'

Gem::Specification.new do |spec|
  spec.name          = 'writedown'
  spec.version       = WriteDown::VERSION
  spec.authors       = ['Jakukyo Friel']
  spec.email         = ['weakish@gmail.com']
  spec.description   = %q{WriteDown is a interface to note taking and todo
managing applications.}
  spec.summary       = %q{Interface to note taking applications.}
  spec.homepage      = 'https://github.com/weakish/writedown'
  spec.license       = '0BSD'
=begin metadata is not supported by gem < 2.0
  spec.metadata      = {
                        'repository' => 'https://github.com/weakish/writedown
.git',
                        'documentation' => 'http://www.rubydoc
.info/gems/writedown',
                        'issues' => 'https://github
.com/weakish/issues/writedown',
                        'wiki' => 'https://github.com/weakish/wiki/writedown',
                       }
=end
  spec.required_ruby_version = '>= 1.9.3'
  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ['lib']
  spec.bindir        = ['bin']

  spec.add_runtime_dependency 'activesupport'
  spec.add_runtime_dependency 'facets'
  spec.add_development_dependency 'bundler', '~> 1.3'
  spec.add_development_dependency 'rake'
  spec.add_development_dependency 'yard-doctest'
end
