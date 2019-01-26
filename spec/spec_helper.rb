
require 'async/rspec'

require 'cloudflare/rspec/connection'
require 'cloudflare/zones'

RSpec.shared_context Cloudflare::Zone do
	include_context Cloudflare::RSpec::Connection
	
	let(:name) {"testing.com"}
	
	let(:account) {connection.accounts.first}
	let(:zones) {connection.zones}
	
	let(:zone) {@zone = zones.find_by_name(name) || zones.create(name, account)}
	
	# after do
	# 	if defined? @zone
	# 		@zone.delete
	# 	end
	# end
end

RSpec.configure do |config|
	# Enable flags like --only-failures and --next-failure
	config.example_status_persistence_file_path = '.rspec_status'

	config.expect_with :rspec do |c|
		c.syntax = :expect
	end
end
