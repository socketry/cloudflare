# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2019-2024, by Samuel Williams.
# Copyright, 2019, by David Wegman.

require "cloudflare/dns"
require "cloudflare/a_connection"

describe Cloudflare::DNS do
	include_context Cloudflare::AConnection

	let(:subdomain) { "www-#{job_id || SecureRandom.hex(4)}" }

	with "new record" do
		it "can create dns record" do
			record = zone.dns_records.create("A", subdomain, "1.2.3.4")

			expect(record.type).to be == "A"
			expect(record.name).to be(:start_with?, subdomain)
			expect(record.content).to be == "1.2.3.4"
				ensure
					record&.delete
		end

		it "can create dns record with proxied option" do
			record = zone.dns_records.create("A", subdomain, "1.2.3.4", proxied: true)

			expect(record.type).to be == "A"
			expect(record.name).to be(:start_with?, subdomain)
			expect(record.content).to be == "1.2.3.4"
			expect(record.proxied).to be_truthy
				ensure
					record&.delete
		end
	end

	with "existing record" do
		let(:record) { zone.dns_records.create("A", subdomain, "1.2.3.4") }

		after do
			@record&.delete
		end

		it "can update dns content" do
			record.update_content("4.3.2.1")
			expect(record.content).to be == "4.3.2.1"

			fetched_record = zone.dns_records.find_by_name(record.name)
			expect(fetched_record.content).to be == record.content
		end

		it "can update dns content with proxied option" do
			record.update_content("4.3.2.1", proxied: true)
			expect(record).to be(:proxied?)

			fetched_record = zone.dns_records.find_by_name(record.name)
			expect(fetched_record).to be(:proxied?)
		end
	end

	describe "#update" do
		let(:subject) { record.update(**new_params) }

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
