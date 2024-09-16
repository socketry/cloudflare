# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2017-2024, by Samuel Williams.
# Copyright, 2018, by Leonhardt Wille.
# Copyright, 2018, by Michael Kalygin.
# Copyright, 2018, by Sherman Koa.
# Copyright, 2019, by Rob Widmer.

require "cloudflare/zones"
require "cloudflare/a_connection"

describe Cloudflare::Zones do
	include_context Cloudflare::AConnection
	
	with "temporary zone" do
		let(:temporary_zone_name) {"#{SecureRandom.hex(8)}-testing.com"}
		
		it "can create and destroy zone" do
			temporary_zone = zones.create(temporary_zone_name, account)
			
			fetched_zone = zones.find_by_name(temporary_zone_name)
			expect(fetched_zone.name).to be == temporary_zone_name
			
			fetched_zone.delete
		end
	end
	
	with "test zone" do
		before do
			# Ensure the zone exists:
			self.zone
		end
		
		it "can list zones" do
			matching_zones = zones.select{|zone| zone.name == zone_name}
			
			expect(matching_zones).not.to be(:empty?)
		end
		
		it "can get zone by name" do
			found_zone = zones.find_by_name(zone_name)
			
			expect(found_zone).to have_attributes(
				name: be == zone_name
			)
		end
	end
end
