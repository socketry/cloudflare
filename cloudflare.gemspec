# frozen_string_literal: true

require_relative "lib/cloudflare/version"

Gem::Specification.new do |spec|
	spec.name = "cloudflare"
	spec.version = Cloudflare::VERSION
	
	spec.summary = "A Ruby wrapper for the Cloudflare API."
	spec.authors = ["Marcin Prokop", "Samuel Williams"]
	spec.license = "MIT"
	
	spec.homepage = "https://github.com/socketry/cloudflare"
	
	spec.files = Dir.glob('{lib}/**/*', File::FNM_DOTMATCH, base: __dir__)
	
	spec.required_ruby_version = ">= 2.5"
	
	spec.add_dependency "async-rest", "~> 0.12.3"
	
	spec.add_development_dependency "async-rspec"
	spec.add_development_dependency "bundler"
	spec.add_development_dependency "covered"
	spec.add_development_dependency "rspec", "~> 3.6"
end
