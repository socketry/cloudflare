# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2019, by Rob Widmer.
# Copyright, 2024, by Samuel Williams.

require "cloudflare/custom_hostname/ssl_attribute"

ACCESSORS = [:cname, :cname_target, :http_body, :http_url, :method, :status, :type, :validation_errors]

describe Cloudflare::CustomHostname::SSLAttribute do
	let(:original_hash) {Hash.new}
	let(:attribute) {subject.new(original_hash)}
	
	ACCESSORS.each do |key|
		it "has an accessor for the #{key} value", unique: key do
			test_value = Object.new
			expect(attribute.send(key)).to be_nil
			
			original_hash[key] = test_value
			expect(attribute.send(key)).to be == test_value
		end
	end
	
	it '#active? returns true when the status is "active" and false otherwise' do
		expect(attribute.active?).to be == false
		original_hash[:status] = "initializing"
		expect(attribute.active?).to be == false
		original_hash[:status] = "pending_validation"
		expect(attribute.active?).to be == false
		original_hash[:status] = "pending_deployment"
		expect(attribute.active?).to be == false
		original_hash[:status] = "active"
		expect(attribute.active?).to be == true
	end
	
	it '#pending_validation? returns true when the status is "pending_validation" and false otherwise' do
		expect(attribute.pending_validation?).to be == false
		original_hash[:status] = "initializing"
		expect(attribute.pending_validation?).to be == false
		original_hash[:status] = "active"
		expect(attribute.pending_validation?).to be == false
		original_hash[:status] = "pending_deployment"
		expect(attribute.pending_validation?).to be == false
		original_hash[:status] = "pending_validation"
		expect(attribute.pending_validation?).to be == true
	end
	
	with "#settings" do
		it "should return a Settings object" do
			expect(attribute.settings).to be_a Cloudflare::CustomHostname::SSLAttribute::Settings
		end
		
		it "initailizes the settings object with the value from the settings key" do
			settings = {min_tls_version: Object.new}
			
			original_hash[:settings] = settings
			
			expect(attribute.settings.min_tls_version).to be == settings[:min_tls_version]
		end
		
		it "initializes the settings object with a new hash if the settings key does not exist" do
			expected_value = Object.new
			
			expect(original_hash[:settings]).to be_nil
			expect(attribute.settings.min_tls_version).to be_nil
			expect(original_hash[:settings]).not.to be_nil
			original_hash[:settings][:min_tls_version] = expected_value
			expect(attribute.settings.min_tls_version).to be == expected_value
		end
		
		it "updates the stored hash with values set on the settings object" do
			expected_value = Object.new
			
			expect(attribute.settings.min_tls_version).to be_nil
			attribute.settings.min_tls_version = expected_value
			expect(original_hash[:settings][:min_tls_version]).to be == expected_value
		end
	end
end
