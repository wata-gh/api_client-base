# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'api_client/base/version'

Gem::Specification.new do |spec|
  spec.name          = "api_client-base"
  spec.version       = ApiClient::Base::VERSION
  spec.authors       = ["shinya-watanabe"]
  spec.email         = ["shinya-watanabe@cookpad.com"]

  spec.summary       = %q{MPDev client base.}
  spec.description   = %q{Office Ruby gem for MPDev client base.}
  spec.homepage      = "https://github.com/wata-gh/api_client-base"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency 'faraday'
  spec.add_dependency 'her'
  spec.add_development_dependency "bundler", "~> 1.14"
  spec.add_development_dependency "rake", "~> 10.0"
end
