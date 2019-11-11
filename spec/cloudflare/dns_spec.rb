
require 'cloudflare/rspec/connection'

RSpec.describe Cloudflare::DNS, order: :defined, timeout: 30 do
	include_context Cloudflare::Zone
	
	let(:subdomain) {"www#{ENV['TRAVIS_JOB_ID']}"}
	
	after do
		if defined? @record
			expect(@record.delete).to be_success
		end
	end
	
	context "new record" do
		it "can create dns record" do
			@record = zone.dns_records.create("A", subdomain, "1.2.3.4")
			expect(@record.type).to be == "A"
			expect(@record.name).to be_start_with subdomain
			expect(@record.content).to be == "1.2.3.4"
		end
		
		it "can create dns record with proxied option" do
			@record = zone.dns_records.create("A", subdomain, "1.2.3.4", proxied: true)
			expect(@record.type).to be == "A"
			expect(@record.name).to be_start_with subdomain
			expect(@record.content).to be == "1.2.3.4"
			expect(@record.proxied).to be_truthy
		end
	end
	
	context "with existing record" do
		let(:record) {@record = zone.dns_records.create("A", subdomain, "1.2.3.4")}
		it "can update dns content" do
			record.update_content("4.3.2.1")
			expect(record.content).to be == "4.3.2.1"
			
			fetched_record = zone.dns_records.find_by_name(record.name)
			expect(fetched_record.content).to be == record.content
		end
		
		it "can update dns content with proxied option" do
			record.update_content("4.3.2.1", proxied: true)
			expect(record.proxied).to be_truthy
			
			fetched_record = zone.dns_records.find_by_name(record.name)
			expect(fetched_record.proxied).to be_truthy
		end
	end
end
