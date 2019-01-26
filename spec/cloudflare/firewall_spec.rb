
require 'cloudflare/rspec/connection'

RSpec.describe Cloudflare::Firewall, order: :defined, timeout: 30 do
	include_context Cloudflare::Zone
	
	let(:notes) {'gemtest'}
	
	context "with several rules" do
		let(:allow_ip) {'123.123.123.123'}
		let(:block_ip) {'123.123.123.124'}
		
		before do
			zone.firewall_rules.each do |rule|
				rule.delete
			end
			
			zone.firewall_rules.set('whitelist', allow_ip)
			zone.firewall_rules.set('block', block_ip)
		end

		it 'should get all rules' do
			rules = zone.firewall_rules.to_a
			
			expect(rules.size).to be >= 2
		end
		
		it 'should get rules with specific value' do
			rules = zone.firewall_rules.each_by_value(allow_ip).to_a
			
			expect(rules.size).to be == 1
		end
	end
	
	%w[block challenge whitelist].each_with_index do |mode, index|
		it "should create a #{mode} rule" do
			value = "123.123.123.#{index}"
			rule = zone.firewall_rules.set(mode, value, notes: notes)
			
			expect(rule.mode).to be == mode
			expect(rule.configuration[:value]).to be == value
			expect(rule.configuration[:target]).to be == 'ip'
			expect(rule.notes).to be == notes
			
			rule.delete
		end
	end
end
