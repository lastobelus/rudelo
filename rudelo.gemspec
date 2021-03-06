# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'rudelo/version'

Gem::Specification.new do |spec|
  spec.name          = "rudelo"
  spec.version       = Rudelo::VERSION
  spec.authors       = ["Michael Johnston"]
  spec.email         = ["lastobelus@mac.com"]
  spec.description   = %q{Set Logic Matcher for rufus-decision}
  spec.summary       = %q{Set Logic Matcher for rufus-decision}
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_dependency  "rufus-decision", "~> 1.4"
  spec.add_dependency  "parslet"
  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "rspec"
end
