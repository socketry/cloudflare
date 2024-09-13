# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2024, by Samuel Williams.

require "cloudflare"
require "sus/fixtures/async/reactor_context"
require "async/http/proxy"

module Cloudflare
	AUTH_EMAIL = ENV["CLOUDFLARE_EMAIL"]
	AUTH_KEY = ENV["CLOUDFLARE_KEY"]
	PROXY_URL = ENV["CLOUDFLARE_PROXY"]
	
	ACCOUNT_ID = ENV["CLOUDFLARE_ACCOUNT_ID"]
	
	ZONE_NAMES = %w{alligator ant bear bee bird camel cat cheetah chicken chimpanzee cow crocodile deer dog dolphin duck eagle elephant fish fly fox frog giraffe goat goldfish hamster hippopotamus horse kangaroo kitten lion lobster monkey octopus owl panda pig puppy rabbit rat scorpion seal shark sheep snail snake spider squirrel tiger turtle wolf zebra}
	
	JOB_ID = ENV.fetch("INVOCATION_ID", "testing").hash
	
	ZONE_NAME = ENV["CLOUDFLARE_ZONE_NAME"] || "#{ZONE_NAMES[JOB_ID % ZONE_NAMES.size]}.com"
	
	if AUTH_EMAIL.nil? || AUTH_EMAIL.empty? || AUTH_KEY.nil? || AUTH_KEY.empty?
		$stderr.puts <<~EOF
			Please make sure you have defined CLOUDFLARE_EMAIL and CLOUDFLARE_KEY in your environment. You can also specify CLOUDFLARE_ZONE_NAME to test with your own zone and CLOUDFLARE_ACCOUNT_ID to use a specific account
		EOF
	end
	
	AConnection = Sus::Shared("a connection") do
		include Sus::Fixtures::Async::ReactorContext
		
		let(:connection) do
			if proxy_url = PROXY_URL
				proxy_endpoint = Async::HTTP::Endpoint.parse(proxy_url)
				@client = Async::HTTP::Client.new(proxy_endpoint)
				@connection = Cloudflare.connect(@client.proxied_endpoint(Connection::ENDPOINT), email: AUTH_EMAIL, key: AUTH_KEY)
			else
				@client = nil
				@connection = Cloudflare.connect(email: AUTH_EMAIL, key: AUTH_KEY)
			end
		end
		
		let(:account) do
			if ACCOUNT_ID
				connection.accounts.find_by_id(ACCOUNT_ID)
			else
				connection.accounts.first
			end
		end
		
		let(:job_id) {JOB_ID}
		let(:zone_names) {ZONE_NAMES}
		let(:zone_name) {ZONE_NAME}
		
		let(:zones) {connection.zones}
		let(:zone) {zones.find_by_name(zone_name) || zones.create(zone_name, account)}
		
		after do
			@connection&.close
			@client&.close
		end
	end
end
