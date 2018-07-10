# frozen_string_literal: true

if ENV['COVERAGE'] || ENV['TRAVIS']
	begin
		require 'simplecov'

		SimpleCov.start do
			add_filter '/spec/'
		end
	rescue LoadError
		warn "Could not load simplecov: #{$ERROR_INFO}"
	end
end

require 'webmock/rspec'
WebMock.disable_net_connect!(allow_localhost: true)

require 'bundler/setup'
require 'cloudflare'
require 'cloudflare/rspec/connection'

def base_url
	%(https://api.cloudflare.com/client/v4)
end

def zone_id
	'1337z0n31d3n71f13r'
end

def stub_get_zones
	stub_request(:get, "#{base_url}/zones/?page=1&per_page=50&scope_type=organization")
			.with(cf_headers)
			.to_return(status: 200, body: cf_results([{
																										name: 'example.com',
																										ip: '123.123.123.123',
																										id: zone_id
																								}]),
								 headers: {})
end

def stub_get_dns_records
	dns_record = {
			"id": 'b12a037696862c2fc1d45a0e288c82a5',
			"type": 'A',
			"name": 'www.example.com',
			"content": '123.123.123.123',
			"ttl": 1,
			"zone_id": zone_id,
			"zone_name": 'example.com'
	}
	stub_request(:get, "#{base_url}/zones/#{zone_id}/dns_records/?page=1&per_page=50&scope_type=organization")
			.with(cf_headers)
			.to_return(status: 200,
								 body: cf_results([dns_record]),
								 headers: {})
end

def stub_create_dns_record
	stub_request(:post, "#{base_url}/zones/#{zone_id}/dns_records")
			.with(cf_headers('Content-Type': 'application/json'))
			.with(
					body: hash_including(:type, :name, :content, :ttl, :proxied)
			)
			.to_return(status: 200,
								 body: cf_results(id: '123231123', type: 'A', name: 'test', content: '123.123.123.123', ttl: 240),
								 headers: {})
end

def stub_find_dns_record_by_id(id)
	stub_request(:get, "#{base_url}/zones/#{zone_id}/dns_records")
			.with(query: {id: id})
			.with(cf_headers)
			.to_return(status: 200,
								 body: cf_results(
										 id: '123231123',
										 type: 'A',
										 name: 'test',
										 content: '123.123.123.123',
										 ttl: 240
								 ),
								 headers: {})
end

def stub_get_dns_record(id)
	stub_request(:get, "#{base_url}/zones/#{zone_id}/dns_records/#{id}")
			.with(cf_headers)
			.to_return(status: 200,
								 body: cf_results(
										 id: '123231123',
										 type: 'A',
										 name: 'test',
										 content: '123.123.123.123',
										 ttl: 240
								 ),
								 headers: {})
end

def stub_delete_dns_record(id)
	stub_request(:delete, "#{base_url}/zones/#{zone_id}/dns_records/#{id}")
			.with(cf_headers)
			.to_return(status: 200, body: cf_results(id: id), headers: {})
end

def stub_find_rule_by_value(ip:)
	stub_request(:get, "#{base_url}/zones/#{zone_id}/firewall/access_rules/rules/?configuration_value=#{ip}")
			.with(cf_headers)
			.to_return(status: 200,
								 body: cf_results([cf_access_rule('block', '123.123.123.124', 'gemtest')]),
								 headers: {})
end

def stub_list_access_rules(page, rules)
	query = URI.encode_www_form(page: page, per_page: 50, scope_type: :organization)
	stub_request(:get, "#{base_url}/zones/#{zone_id}/firewall/access_rules/rules/?#{query}")
			.with(cf_headers)
			.to_return(status: 200, body: cf_results(rules), headers: {})
end

def stub_get_access_rule(id)
	stub_request(:get, "#{base_url}/zones/#{zone_id}/firewall/access_rules/rules/#{id}")
			.with(cf_headers)
			.to_return(status: 200,
								 body: cf_results(cf_access_rule('whitelist', '123.123.123.124', 'gemtest', id)),
								 headers: {})
end

def stub_delete_access_rule(id: nil)
	stub_request(:delete, "#{base_url}/zones/#{zone_id}/firewall/access_rules/rules/#{id}")
			.with(cf_headers)
			.to_return(status: 200, body: cf_results(id: id), headers: {})
end

def stub_create_rule(mode, ip, note)
	notes = "cloudflare gem firewall_rules [#{mode}] #{note} #{Time.now.strftime('%m/%d/%y')}"
	body = "{\"mode\":\"#{mode}\",\"configuration\":{\"target\":\"ip\",\"value\":\"#{ip}\",\"notes\":\"#{notes}\"}}"
	stub_request(:post, "https://api.cloudflare.com/client/v4/zones/#{zone_id}/firewall/access_rules/rules")
			.with(cf_headers(
								'Content-Length' => body.bytesize,
								'Content-Type' => 'application/json'
						))
			.with(body: body)
			.to_return(status: 200, body: cf_results(cf_access_rule(mode, ip, notes)), headers: {})
end

def stub_purge_cache
	stub_request(:post, "#{base_url}/zones/#{zone_id}/purge_cache")
			.with(cf_headers)
			.to_return(status: 200, body: cf_results(id: zone_id), headers: {})
end

RSpec.configure do |config|
	# Enable flags like --only-failures and --next-failure
	config.example_status_persistence_file_path = '.rspec_status'

	config.expect_with :rspec do |c|
		c.syntax = :expect
	end
end

def cf_results(result, messages = [], errors = [])
	{result: result, success: true, messages: messages, errors: errors}.to_json
end

def cf_headers(extra = {})
	{headers: {
			'Accept' => '*/*',
			'Accept-Encoding' => 'gzip, deflate',
			'Host' => 'api.cloudflare.com',
			'X-Auth-Email' => 'jake@example.net',
			'X-Auth-Key' => '5up3rS3cr3tAuthK3y',
			'X-Auth-User-Service-Key' => ''
	}.merge(extra)}
end

def cf_access_rule(mode, ip, note, id = '12312312' + ip.slice(-1))
	{id: id, mode: mode, notes: note, configuration: {}}
end
