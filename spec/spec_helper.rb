
if ENV['COVERAGE'] || ENV['TRAVIS']
	begin
		require 'simplecov'
		
		SimpleCov.start do
			add_filter "/spec/"
		end
		
		if ENV['TRAVIS']
			require 'coveralls'
			Coveralls.wear!
		end
	rescue LoadError
		warn "Could not load simplecov: #{$!}"
	end
end

require "bundler/setup"
require "cloudflare"

RSpec.shared_context Cloudflare::Connection do
	# You must specify these in order for the tests to run.
	let(:email) {ENV['CLOUDFLARE_EMAIL']}
	let(:key) {ENV['CLOUDFLARE_KEY']}
	let(:connection) {Cloudflare::Connection.new(key: key, email: email)}
end

RSpec.configure do |config|
	# Enable flags like --only-failures and --next-failure
	config.example_status_persistence_file_path = ".rspec_status"

	config.expect_with :rspec do |c|
		c.syntax = :expect
	end
end
