# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'grape_devise_token_auth/version'

Gem::Specification.new do |spec|
  spec.name          = "grape_devise_token_auth"
  spec.version       = GrapeDeviseTokenAuth::VERSION
  spec.authors       = ["Michael Cordell"]
  spec.email         = ["mike@mikecordell.com"]

  spec.summary       = %q{Allows an existing devise_token_auth/rails project to authenticate a Grape API}
  spec.homepage      = "https://github.com/mcordell/grape_devise_token_auth"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.8"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_dependency 'grape', '> 0.9.0'
  spec.add_dependency 'devise', '~> 3.3'
  spec.add_dependency 'devise_token_auth', '~> 0.1.37'
end
