# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2019, by Rob Widmer.
# Copyright, 2019-2024, by Samuel Williams.

RSpec.describe Cloudflare::KV::Namespaces, kv_spec: true, order: :defined, timeout: 30 do
	include_context Cloudflare::Account

	let(:namespace) { @namespace = account.kv_namespaces.create(namespace_title) }
	let(:namespace_title) { "Test NS ##{rand(1..100)}" }

	after do
		if defined? @namespace
			expect(@namespace.delete).to be_success
		end
	end

	it "can create a namespace" do
		expect(namespace).to be_kind_of Cloudflare::KV::Namespace
		expect(namespace.id).not_to be_nil
		expect(namespace.title).to eq namespace_title
	end

	it "can find a namespace by title" do
		namespace # Call this so that the namespace gets created
		expect(account.kv_namespaces.find_by_title(namespace_title).id).to eq namespace.id
	end

	it "can rename the namespace" do
		new_title = "#{namespace_title}-#{rand(1..100)}"
		namespace.rename(new_title)
		expect(namespace.title).to eq new_title
		expect(account.kv_namespaces.find_by_title(new_title).id).to eq namespace.id
		expect(account.kv_namespaces.find_by_title(namespace_title)).to be_nil
	end

	it "can store a key/value, read it back" do
		key = "key-#{rand(1..100)}"
		value = rand(100..999)
		namespace.write_value(key, value)
		expect(account.kv_namespaces.find_by_id(namespace.id).read_value(key)).to eq value.to_s
	end

	it "can read a previously stored key" do
		key = "key-#{rand(1..100)}"
		value = rand(100..999)
		expect(account.kv_namespaces.find_by_id(namespace.id).write_value(key, value)).to be true
		expect(namespace.read_value(key)).to eq value.to_s
	end

	it "can delete keys" do
		key = "key-#{rand(1..100)}"
		value = rand(100..999)
		expect(namespace.write_value(key, value)).to be true
		expect(namespace.read_value(key)).to eq value.to_s
		expect(namespace.delete_value(key)).to be true
		expect do
			account.kv_namespaces.find_by_id(namespace.id).read_value(key)
		end.to raise_error(Cloudflare::RequestError)
	end

	it "can get the keys that exist in the namespace" do
		counter = 0
		keys = Array.new(rand(1..9)) { "key-#{counter += 1}" } # Keep this single digits so ordering works
		keys.each_with_index do |key, i|
			namespace.write_value(key, i)
		end

		saved_keys = account.kv_namespaces.find_by_id(namespace.id).keys.to_a
		expect(saved_keys.length).to eq keys.length
		saved_keys.each_with_index do |key, i|
			expect(key.name).to eq keys[i]
		end
	end
end
