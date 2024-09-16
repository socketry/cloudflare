# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2019, by Rob Widmer.
# Copyright, 2019-2024, by Samuel Williams.

require "cloudflare/kv/namespaces"
require "cloudflare/a_connection"

describe Cloudflare::KV::Namespaces do
	include_context Cloudflare::AConnection
	
	let(:namespace_title) {"Test Worker #{SecureRandom.hex(4)}"}
	let(:namespace) {account.kv_namespaces.create(namespace_title) }
	
	after do
		@namespace&.delete
	end
	
	it "can create a namespace" do
		expect(namespace).to be_a(Cloudflare::KV::Namespace)
		expect(namespace.id).to be =~ /\A[a-f0-9]{32}\z/
		expect(namespace.title).to be == namespace_title
		
		fetched_namespace = account.kv_namespaces.find_by_title(namespace_title)
		expect(fetched_namespace).to have_attributes(
			id: be == namespace.id
		)
	end

	it "can rename the namespace" do
		new_title = namespace_title + " Renamed"
		
		namespace.rename(new_title)
		
		expect(namespace.title).to be == new_title
		
		fetched_namespace = account.kv_namespaces.find_by_title(new_title)
		expect(fetched_namespace).to have_attributes(
			id: be == namespace.id
		)
	end

	it "can store a key/value, read it back" do
		key = "key-#{rand(1..100)}"
		value = rand(100..999)
		
		expect(namespace.write_value(key, value)).to be == true
		
		fetched_namespace = account.kv_namespaces.find_by_id(namespace.id)
		expect(fetched_namespace.read_value(key)).to be == value.to_s
	end

	it "can delete keys" do
		key = "key-#{SecureRandom.hex(8)}"
		value = SecureRandom.hex(32)
		
		namespace.write_value(key, value)
		expect(namespace.read_value(key)).to be == value.to_s
		expect(namespace.delete_value(key)).to be == true
		
		# This doesn't always reliably fail, so we can't test it:
		#
		# fetched_namespace = account.kv_namespaces.find_by_id(namespace.id)
		#
		# expect do
		# 	fetched_namespace.read_value(key)
		# end.to raise_exception(Cloudflare::RequestError)
	end

	it "can get the keys that exist in the namespace" do
		keys = 10.times.map{|index| "key-#{index}"}
		
		keys.each do |key|
			namespace.write_value(key, key)
		end
		
		fetched_keys = account.kv_namespaces.find_by_id(namespace.id).keys.map(&:name)
		
		expect(fetched_keys.sort).to be == keys.sort
	end
end
