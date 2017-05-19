
RSpec.describe "Cloudflare DNS Zones" do
	include_context Cloudflare::Connection
	
	it "should list zones" do
		zones = connection.zones.all
		
		expect(zones).to be_any
	end
end
