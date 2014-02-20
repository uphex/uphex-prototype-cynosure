# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'uphex/prototype/cynosure/version'

Gem::Specification.new do |spec|
  spec.name          = "uphex-prototype-cynosure"
  spec.version       = Uphex::Prototype::Cynosure::VERSION
  spec.authors       = ["sashee"]
  spec.email         = ["gsashee@gmail.com"]
  spec.description   = %q{Uphex Shiatsu}
  spec.summary       = %q{OAuth data fetcher}
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "rspec"

  spec.add_dependency "oauth2"
  spec.add_dependency "legato"
end
