# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2017-2024, by Samuel Williams.
# Copyright, 2018, by Leonhardt Wille.

require "async/rspec"
require "async/http/proxy"

require_relative "../../cloudflare"

module Cloudflare
	module RSpec
		module Connection
		end
		
		RSpec.shared_context Connection do
			include_context Async::RSpec::Reactor
			
			# You must specify these in order for the tests to run.
			let(:email) {ENV["CLOUDFLARE_EMAIL"]}
			let(:key) {ENV["CLOUDFLARE_KEY"]}
			
			let(:connection) do
				if proxy_url = ENV["CLOUDFLARE_PROXY"]
					proxy_endpoint = Async::HTTP::Endpoint.parse(proxy_url)
					@client = Async::HTTP::Client.new(proxy_endpoint)
					@connection = Cloudflare.connect(@client.proxied_endpoint(DEFAULT_ENDPOINT), key: key, email: email)
				else
					@client = nil
					@connection = Cloudflare.connect(key: key, email: email)
				end
			end
			
			after do
				@connection&.close
				@client&.close
			end
		end
	end
end
