
RSpec.describe "Cloudflare DNS Zones" do
	include_context Cloudflare::RSpec::Connection
	
	it "should list zones" do
		zones = connection.zones.all
		
		expect(zones).to be_any
	end
	
	describe Cloudflare::DNSRecords, order: :defined do
		let(:zone) {connection.zones.all.first}
		let(:name) {"test"}
		
		it "should create dns record" do
			response = zone.dns_records.post({
				type: "A",
				name: name,
				content: "127.0.0.1",
				ttl: 240,
				proxied: false
			}.to_json, content_type: 'application/json')
			
			expect(response).to be_successful
			
			result = response.result
			expect(result).to include(:id, :type, :name, :content, :ttl)
		end
		
		it "should delete dns record" do
			dns_records = zone.dns_records.all
			
			expect(dns_records).to be_any
			
			dns_records.each do |record|
				response = record.delete
				expect(response).to be_successful
			end
		end
	end
end
