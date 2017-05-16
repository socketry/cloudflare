
RSpec.describe "Cloudflare DNS Zones" do
	include_context Cloudflare::Connection
	
	it "should list zones" do
		expect(connection['zones'].get.results).to be_any
	end
end
