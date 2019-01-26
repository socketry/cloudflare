
RSpec.describe Cloudflare::Zones, order: :defined, timeout: 30 do
	include_context Cloudflare::Zone
	
	it "can delete existing domain if exists" do
		if zone = zones.find_by_name(name)
			expect(zone.delete).to be_success
		end
	end
	
	it "can create zone" do
		zone = zones.create(name, account)
		expect(zone.value).to include(:id)
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
