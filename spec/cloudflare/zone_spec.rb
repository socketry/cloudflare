
require 'cloudflare/rspec/connection'

require 'pry'

RSpec.describe Cloudflare::Zones, order: :defined, timeout: 30 do
	include_context Cloudflare::RSpec::Connection
	
	let(:account) {connection.accounts.first}
	let(:name) {"nonexistant.com"}
	
	it "can delete existing domain if exists" do
		if zone = connection.zones.find_by_name(name)
			expect(zone.delete).to be_success
		end
	end
	
	it "can create zone" do
		zone = connection.zones.create(name, account)
		expect(zone.value).to include(:id)
	end
	
	it "can list zones" do
		zones = connection.zones.select{|zone| zone.name == name}
		expect(zones).to_not be_empty
	end
	
	it "can get zone by name" do
		found_zone = connection.zones.find_by_name(name)
		expect(found_zone.name).to be == name
	end
end
