# Copyright, 2012, by Marcin Prokop.
# Copyright, 2017, by Samuel G. D. Williams. <http://www.codeotaku.com>
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
# THE SOFTWARE.

# added firewall rules support: david rosenbloom|davidr@artifactory.com|artifactory
#
require_relative 'connection'

module Cloudflare
	class Connection < Resource
		def zones
			@zones ||= Zones.new(concat_urls(url, 'zones'), options)
		end
	end

	class DNSRecord < Resource
		def initialize(url, record = nil, **options)
			super(url, **options)

			@record = record || self.get.result
		end


		def update_content(content)
			response = self.put({type: @record[:type], name: @record[:name], content: content}.to_json, content_type: 'application/json')
			response.successful?
		end

		attr :record

		def to_s
			"#{@record[:name]} #{@record[:type]} #{@record[:content]}"
		end
	end

	class DNSRecords < Resource
		def initialize(url, zone, **options)
			super(url, **options)

			@zone = zone
		end

		attr :zone

		def all
			results = paginate(DNSRecords, url)
			results.map{|record| DNSRecord.new(concat_urls(url, record[:id]), record, **options)}
		end

		def find_by_name(name)
			response = self.get(params: {name: name})

			unless response.empty?
				record = response.results.first

				DNSRecord.new(concat_urls(url, record[:id]), record, **options)
			end
		end

		def find_by_id(id)
			DNSRecord.new(concat_urls(url, id), **options)
		end
	end

	class FirewallRule < Resource
		def initialize(url, record = nil, **options)
			super(url, **options)

			@record = record || self.get.result
		end

		attr :record

		def to_s
			"#{@record[:configuration][:value]} - #{@record[:mode]} - #{@record[:notes]}"
		end
	end

	class FirewallRules < Resource
		def initialize(url, zone, **options)
			super(url, **options)

			@zone = zone
		end

		attr :zone

		def all(mode = nil, ip = nil, notes = nil)
			url_args = ""
			url_args.concat("&mode=#{mode}") if mode
			url_args.concat("&configuration_value=#{ip}") if ip
			url_args.concat("&notes=#{notes}") if notes

			results = paginate(FirewallRules, url, url_args)
			results.map{|record| FirewallRule.new(concat_urls(url, record[:id]), record, **options)}
		end

		def firewalled_ips(rules)
			rules.collect {|r| r.record[:configuration][:value]}
		end

		def blocked_ips
			firewalled_ips(all("block"))
		end

		def set(mode, ip, note)
			data = {"mode":"#{mode.to_s}","configuration":{"target":"ip","value":"#{ip}"},"notes":"cloudflare gem firewall_rules [#{mode}] #{note} #{Time.now.strftime("%m/%d/%y")} "}
			post(data.to_json, content_type: 'application/json')
		end

		def unset(mode, value)
			rule = send("find_by_#{mode}", value)
			rule.delete
		end

		def find_by_id(id)
			FirewallRule.new(concat_urls(url, id), **options)
		end

		def find_by_ip(ip)
			rule = FirewallRule.new(concat_urls(url, "?configuration_value=#{ip}"), **options)
			FirewallRule.new(concat_urls(url, rule.record.first[:id]), **options)
		end
	end

	class Zone < Resource
		def initialize(url, record = nil, **options)
			super(url, **options)
			@record = record || self.get.result
		end

		attr :record

		def dns_records
			@dns_records ||= DNSRecords.new(concat_urls(url, 'dns_records'), self, **options)
		end

		def firewall_rules
			@firewall_rules ||= FirewallRules.new(concat_urls(url, "firewall/access_rules/rules"), self, **options)
		end

		def to_s
			@record[:name]
		end
	end

	class Zones < Resource
		def all
			self.get.results.map{|record| Zone.new(concat_urls(url, record[:id]), record, **options)}
		end

		def find_by_name(name)
			response = self.get(params: {name: name})

			unless response.empty?
				record = response.results.first

				Zone.new(concat_urls(url, record[:id]), record, **options)
			end
		end

		def find_by_id(id)
			Zone.new(concat_urls(url, id), **options)
		end
	end
end
