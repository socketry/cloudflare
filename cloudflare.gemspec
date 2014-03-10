# -*- encoding: utf-8 -*-
$LOAD_PATH.push File.expand_path("../lib", __FILE__)
require 'cloudflare/version'

Gem::Specification.new do |s|
	s.name        = 'cloudflare'
	s.version     = CloudFlare::VERSION
	s.platform          = Gem::Platform::RUBY

	s.description = 'A Ruby wrapper for the CloudFlare API.'
	s.summary     = 'A Ruby wrapper for the CloudFlare API.'
	s.authors     = ['Marcin Prokop']
	s.email       = 'marcin@prokop.co'
	s.homepage    = 'https://github.com/b4k3r/cloudflare'
	s.licenses    = ['MIT']

	s.files            = `git ls-files`.split("\n")
	s.test_files       = ['test/test_cloudflare.rb']
	s.rdoc_options     = ['--main', 'README.md', '--charset=UTF-8']
	s.extra_rdoc_files = ['README.md', 'LICENSE']

	s.required_ruby_version = '>= 1.9.0'
	s.add_runtime_dependency 'json', '~> 1'
	s.add_development_dependency 'rake'
end
