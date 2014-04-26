# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'flat-ui-sass/version'

Gem::Specification.new do |spec|
  spec.name          = "flat-ui-sass"
  spec.version       = FlatUI::VERSION
  spec.authors       = ["Stafford Brunk"]
  spec.email         = ["stafford.brunk@gmail.com"]
  spec.description   = %q{SASS conversion of Designmodo's Flat UI Free along with tools to convert Flat UI Pro}
  spec.summary       = %q{An automatic SASS conversion of Designmodo's Flat UI Free along with tools to automatically convert Flat UI Pro to SASS}
  spec.homepage      = "https://github.com/wingrunr21/flat-ui-sass"
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_dependency "bootstrap-sass", ">= 3.1"
  spec.add_dependency "sass", ">= 3.2.0"

  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "compass"
  spec.add_development_dependency "sass-rails", ">= 3.2"
end
