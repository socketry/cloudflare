# frozen_string_literal: true

AUTH_EMAIL = ENV['CLOUDFLARE_EMAIL']
AUTH_KEY = ENV['CLOUDFLARE_KEY']

if AUTH_EMAIL.nil? || AUTH_EMAIL.empty? || AUTH_KEY.nil? || AUTH_KEY.empty?
	puts 'Please make sure you have defined CLOUDFLARE_EMAIL and CLOUDFLARE_KEY in your environment'
	puts 'You can also specify CLOUDFLARE_ZONE_NAME to test with your own zone and'
	puts 'CLOUDFLARE_ACCOUNT_ID to use a specific account'
	exit(1)
end

ACCOUNT_ID = ENV['CLOUDFLARE_ACCOUNT_ID']
NAMES = ['testing', 'horse', 'cat', 'dog', 'fish', 'dolphin', 'lion', 'tiger'].freeze
JOB_ID = ENV.fetch('TRAVIS_JOB_ID', 0).to_i
ZONE_NAME = ENV['CLOUDFLARE_ZONE_NAME'] || "#{NAMES[JOB_ID % NAMES.size]}.com"

require 'covered/rspec'
require 'async/rspec'

require 'cloudflare/rspec/connection'
require 'cloudflare/zones'

RSpec.shared_context Cloudflare::Account do
	include_context Cloudflare::RSpec::Connection

	let(:account) do
		if ACCOUNT_ID
			connection.accounts.find_by_id(ACCOUNT_ID)
		else
			connection.accounts.first
		end
	end

end

RSpec.shared_context Cloudflare::Zone do
	include_context Cloudflare::Account

	let(:job_id) { JOB_ID }
	let(:names) { NAMES.dup }
	let(:name) { ZONE_NAME.dup }

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

	disabled_specs = {}

	# Check for features the current account has enabled
	Cloudflare.connect(key: AUTH_KEY, email: AUTH_EMAIL) do |conn|
		begin
			account = if ACCOUNT_ID
				conn.accounts.find_by_id(ACCOUNT_ID)
			else
				conn.accounts.first
			end
			account.kv_namespaces.to_a
		rescue Cloudflare::RequestError => e
			if e.message.include?('your account is not entitled')
				puts 'Disabling KV specs due to no access'
				disabled_specs[:kv_spec] = true
			else
				raise
			end
		end
	end

	config.filter_run_excluding disabled_specs unless disabled_specs.empty?
end
