# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2025, by Ivan Vergés.

require "cloudflare/r2/buckets"
require "cloudflare/a_connection"

describe Cloudflare::R2::Buckets do
	include_context Cloudflare::AConnection

	let(:temporary_zone_name) { "#{SecureRandom.hex(8)}-testing.com" }
	let(:bucket_name) { "test-bucket-#{SecureRandom.hex(4)}" }
	let(:bucket) { account.r2_buckets.create(bucket_name) }

	after do
		@bucket&.delete
	end

	it "can create a bucket" do
		expect(bucket).to be_a(Cloudflare::R2::Bucket)
		expect(bucket.name).to be == bucket_name

		fetched_bucket = account.r2_buckets.find_by_name(bucket_name)
		expect(fetched_bucket).to have_attributes(
						name: be == bucket.name
						)
	end

	it "can attach a domain to a bucket" do
		temporary_zone = zones.create(temporary_zone_name, account)
		payload = { zoneId: temporary_zone.id, enabled: true }
		
		# this is a workaround as the domain must have the DNS records set up correctly for this to work
		expect do
			bucket.domains.attach("subdomain.#{temporary_zone.name}", **payload)
		end.to raise_exception(Cloudflare::RequestError, message: be =~ /The specified zone id is not valid/)

		temporary_zone.delete
	end

	it "can create a CORS policy" do
		rules = [
		{
			allowed: {
				methods: ["GET", "PUT"],
				headers: ["*"],
				origins: ["https://example.com"]
			},
			exposeHeaders: [
				"Origin",
			],
			maxAgeSeconds: 3600
		}
		]
		cors = bucket.create_cors(account_id: account.id, rules: rules)
		expect(cors).to be_a(Cloudflare::R2::Cors)
	end
end