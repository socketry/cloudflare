# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2019, by Rob Widmer.
# Copyright, 2024, by Samuel Williams.

require "cloudflare/accounts"
require "cloudflare/a_connection"

describe Cloudflare::Accounts do
	include_context Cloudflare::AConnection
	
	before do
		# Force a fetch if it hasn't happened yet:
		account.id
	end
	
	it "can list existing accounts" do
		accounts = connection.accounts.to_a
		
		expect(accounts).to have_value(have_attributes(
			id: be == account.id
		))
	end
	
	it "can get a specific account" do
		fetched_account = connection.accounts.find_by_id(account.id)
		
		expect(fetched_account.id).to be == account.id
	end
	
	it "can generate a representation for the KV namespace endpoint" do
		namespace = connection.accounts.find_by_id(account.id).kv_namespaces
		
		expect(namespace).to be_a(Cloudflare::KV::Namespaces)
		
		expect(namespace.resource.reference.path).to be(:end_with?, "/#{account.id}/storage/kv/namespaces")
	end
end
