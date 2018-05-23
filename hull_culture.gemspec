# frozen_string_literal: true

lib = File.expand_path('../lib', __FILE__)

$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

require 'hull_culture/version'

Gem::Specification.new do |spec|
  spec.name          = 'hull_culture'
  spec.version       = HullCulture::VERSION
  spec.authors       = ['Julie Allinson']
  spec.email         = ['julie.allinson@london.ac.uk']

  spec.summary       = 'Hyrax app generation for Hull Culture.'

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']
end
