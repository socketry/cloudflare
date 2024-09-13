# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2019, by Rob Widmer.
# Copyright, 2024, by Samuel Williams.

require "cloudflare/custom_hostname/ssl_attribute/settings"

describe Cloudflare::CustomHostname::SSLAttribute::Settings do
	let(:settings) {subject.new}
	
	it "has an accessor for ciphers" do
		ciphers = Object.new
		expect(settings.ciphers).to be_nil
		settings.ciphers = ciphers
		expect(settings.ciphers).to be == ciphers
	end
	
	it "has a boolean accessor for http2" do
		expect(settings.http2).to be_nil
		expect(settings.http2?).to be == false
		settings.http2 = true
		expect(settings.http2).to be == "on"
		expect(settings.http2?).to be == true
		settings.http2 = false
		expect(settings.http2).to be == "off"
		expect(settings.http2?).to be == false
		settings.http2 = "on"
		expect(settings.http2).to be == "on"
		expect(settings.http2?).to be == true
		settings.http2 = "off"
		expect(settings.http2).to be == "off"
		expect(settings.http2?).to be == false
	end
	
	it "has an accessor for min_tls_version" do
		tls_version = Object.new
		expect(settings.min_tls_version).to be_nil
		settings.min_tls_version = tls_version
		expect(settings.min_tls_version).to be == tls_version
	end
	
	it "has a boolean accessor for tls_1_3" do
		expect(settings.tls_1_3).to be_nil
		expect(settings.tls_1_3?).to be == false
		settings.tls_1_3 = true
		expect(settings.tls_1_3).to be == "on"
		expect(settings.tls_1_3?).to be == true
		settings.tls_1_3 = false
		expect(settings.tls_1_3).to be == "off"
		expect(settings.tls_1_3?).to be == false
		settings.tls_1_3 = "on"
		expect(settings.tls_1_3).to be == "on"
		expect(settings.tls_1_3?).to be == true
		settings.tls_1_3 = "off"
		expect(settings.tls_1_3).to be == "off"
		expect(settings.tls_1_3?).to be == false
	end
end
