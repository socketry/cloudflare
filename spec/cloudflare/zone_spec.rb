# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2017-2019, by Samuel Williams.
# Copyright, 2018, by Leonhardt Wille.
# Copyright, 2018, by Michael Kalygin.
# Copyright, 2018, by Sherman K.
# Copyright, 2019, by Rob Widmer.

RSpec.describe Cloudflare::Zones, order: :defined, timeout: 30 do
	include_context Cloudflare::Zone

	if ENV["CLOUDFLARE_TEST_ZONE_MANAGEMENT"] == "true"
		it "can delete existing domain if exists" do
			if zone = zones.find_by_name(name)
				expect(zone.delete).to be_success
			end
		end

		it "can create a zone" do
			zone = zones.create(name, account)
			expect(zone.value).to include(:id)
		end
	end

	it "can list zones" do
		matching_zones = zones.select{|zone| zone.name == name}
		expect(matching_zones).to_not be_empty
	end

	it "can get zone by name" do
		found_zone = zones.find_by_name(name)
		expect(found_zone.name).to be == name
	end
end
