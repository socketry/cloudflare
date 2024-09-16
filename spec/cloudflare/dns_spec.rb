
require 'cloudflare/rspec/connection'

RSpec.describe Cloudflare::DNS, order: :defined, timeout: 30 do
	include_context Cloudflare::Zone
	
	let(:subdomain) {"www-#{job_id}"}
	
	after do
		if defined? @record
			expect(@record.delete).to be_success
		end
	end
	
	describe "#create" do
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
	
	describe "#update_content" do
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

	describe "#update" do
		let(:subject) { record.update(**new_params)}

		let(:record) { @record = zone.dns_records.create("A", "old", "1.2.3.4", proxied: false) }

		let(:new_params) do
			{
				type: "CNAME",
				name: "new",
				content: "example.com",
				proxied: true
			}
		end

		it "can update dns record" do
			expect { subject }.to change { record.name }.to("#{new_params[:name]}.#{zone.name}")
				.and change { record.type }.to(new_params[:type])
				.and change { record.content }.to(new_params[:content])
				.and change { record.proxied }.to(new_params[:proxied])
		end
	end
end
