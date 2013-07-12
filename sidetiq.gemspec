# -*- encoding: utf-8 -*-
lib = File.expand_path(File.join('..', 'lib'), __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'sidetiq/version'

Gem::Specification.new do |gem|
  gem.name          = "sidetiq"
  gem.version       = Sidetiq::VERSION::STRING
  gem.authors       = ["Tobias Svensson"]
  gem.email         = ["tob@tobiassvensson.co.uk"]
  gem.description   = "Recurring jobs for Sidekiq"
  gem.summary       = gem.description
  gem.homepage      = "http://github.com/tobiassvn/sidetiq"
  gem.license       = "3-clause BSD"

  gem.files         = `git ls-files`.split($/)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ["lib"]
  gem.extensions    = []

  gem.add_dependency 'sidekiq',  '~> 2.13.0'
  gem.add_dependency 'ice_cube', '~> 0.11.0'
end
