
# frozen_string_literal: true

require_relative 'lib/cloudflare/version'

Gem::Specification.new do |spec|
	spec.name     = 'cloudflare'
	spec.version  = Cloudflare::VERSION
	spec.platform = Gem::Platform::RUBY

	spec.summary     = 'A Ruby wrapper for the Cloudflare API.'
	spec.authors     = ['Marcin Prokop', 'Samuel Williams']
	spec.email       = ['marcin@prokop.co', 'samuel.williams@oriontransfer.co.nz']
	spec.homepage    = 'https://github.com/b4k3r/cloudflare'
	spec.licenses    = ['MIT']

	spec.files         = `git ls-files`.split("\n")
	spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
	spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
	spec.require_paths = ['lib']

	spec.required_ruby_version = '>= 2.0.0'

	spec.add_dependency 'async-rest', '~> 0.10.0'

	spec.add_development_dependency 'async-rspec'

	spec.add_development_dependency 'covered'
	spec.add_development_dependency 'bundler'
	spec.add_development_dependency 'rake'
	spec.add_development_dependency 'rspec', '~> 3.6'
end
