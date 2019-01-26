
require 'cloudflare/rspec/connection'

RSpec.describe Cloudflare::DNS, order: :defined, timeout: 30 do
	include_context Cloudflare::Zone
	
	let(:subdomain) {"dyndns#{Time.now.to_i}"}
	
	let(:record) {@record = zone.dns_records.create("A", subdomain, "1.2.3.4")}
	
	after do
		if defined? @record
			expect(@record.delete).to be_success
		end
	end
	
	it "can create dns record" do
		expect(record.type).to be == "A"
		expect(record.name).to be_start_with subdomain
		expect(record.content).to be == "1.2.3.4"
	end
	
	context "with existing record" do
		it "can update dns content" do
			record.update_content("4.3.2.1")
			expect(record.content).to be == "4.3.2.1"
			
			fetched_record = zone.dns_records.find_by_name(record.name)
			expect(fetched_record.content).to be == record.content
		end
	end
end
