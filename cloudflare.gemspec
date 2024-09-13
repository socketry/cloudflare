# frozen_string_literal: true

require_relative "lib/cloudflare/version"

Gem::Specification.new do |spec|
	spec.name = "cloudflare"
	spec.version = Cloudflare::VERSION
	
	spec.summary = "A Ruby wrapper for the Cloudflare API."
	spec.authors = ["Samuel Williams", "Marcin Prokop", "Leonhardt Wille", "Rob Widmer", "Akinori Musha", "Sherman Koa", "Michael Kalygin", "Denis Sadomowski", "Eric McKay", "Fedishin Nazar", "Casey Lopez", "David Wegman", "Greg Retkowski", "Guillaume Leseur", "Jason Green", "Kugayama Nana", "Kyle Corbitt", "Mike Perham", "Olle Jonsson", "Terry Kerr", "莫粒"]
	spec.license = "MIT"
	
	spec.cert_chain  = ["release.cert"]
	spec.signing_key = File.expand_path("~/.gem/release.pem")
	
	spec.homepage = "https://github.com/socketry/cloudflare"
	
	spec.metadata = {
		"source_code_uri" => "https://github.com/socketry/cloudflare.git",
	}
	
	spec.files = Dir.glob(["{lib}/**/*", "*.md"], File::FNM_DOTMATCH, base: __dir__)
	
	spec.required_ruby_version = ">= 3.1"
	
	spec.add_dependency "async-rest", "~> 0.18"
end
