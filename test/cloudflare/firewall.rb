# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2019-2024, by Samuel Williams.

require "cloudflare/firewall"
require "cloudflare/a_connection"

describe Cloudflare::Firewall do
	include_context Cloudflare::AConnection
	
	let(:notes) {"gemtest"}
	
	with "several rules" do
		let(:allow_ip) {"123.123.123.123"}
		let(:block_ip) {"123.123.123.124"}
		
		before do
			zone.firewall_rules.each do |rule|
				rule.delete
			end
			
			zone.firewall_rules.set("whitelist", allow_ip)
			zone.firewall_rules.set("block", block_ip)
		end

		it "should get all rules" do
			rules = zone.firewall_rules.to_a
			
			expect(rules.size).to be >= 2
		end
		
		it "should get rules with specific value" do
			rules = zone.firewall_rules.each_by_value(allow_ip).to_a
			
			expect(rules.size).to be == 1
		end
	end
	
	%w[block challenge whitelist].each_with_index do |mode, index|
		it "should create a #{mode} rule", unique: mode do
			value = "1.2.3.#{index}"
			rule = zone.firewall_rules.set(mode, value, notes: notes)
			
			expect(rule.mode).to be == mode
			expect(rule.configuration[:value]).to be == value
			expect(rule.configuration[:target]).to be == "ip"
			expect(rule.notes).to be == notes
			
		ensure
			rule&.delete
		end
	end
end
