# frozen_string_literal: true

RSpec.describe Cloudflare::Accounts, order: :defined, timeout: 30 do
	include_context Cloudflare::Account

	before do
		account.id # Force a fetch if it hasn't happened yet
	end

	it 'can list existing accounts' do
		accounts = connection.accounts.to_a
		expect(accounts.any? {|a| a.id == account.id }).to be true
	end

	it 'can get a specific account' do
		expect(connection.accounts.find_by_id(account.id).id).to eq account.id
	end

	it 'can generate a representation for the KV namespace endpoint' do
		ns = connection.accounts.find_by_id(account.id).kv_namespaces
		expect(ns).to be_kind_of(Cloudflare::KV::Namespaces)
		expect(ns.resource.reference.path).to end_with("/#{account.id}/storage/kv/namespaces")
	end
end
