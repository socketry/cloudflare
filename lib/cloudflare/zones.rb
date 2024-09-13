# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2017-2024, by Samuel Williams.
# Copyright, 2017, by Denis Sadomowski.
# Copyright, 2017, by 莫粒.
# Copyright, 2018, by Leonhardt Wille.
# Copyright, 2018, by Michael Kalygin.
# Copyright, 2018, by Sherman Koa.
# Copyright, 2018, by Kugayama Nana.
# Copyright, 2018, by Casey Lopez.
# Copyright, 2019, by Akinori Musha.
# Copyright, 2019, by Rob Widmer.

require_relative "representation"
require_relative "paginate"

require_relative "custom_hostnames"
require_relative "firewall"
require_relative "dns"
require_relative "logs"

module Cloudflare
	class Zone < Representation
		include Async::REST::Representation::Mutable
		
		def custom_hostnames
			self.with(CustomHostnames, path: "custom_hostnames")
		end

		def dns_records
			self.with(DNS::Records, path: "dns_records")
		end
		
		def firewall_rules
			self.with(Firewall::Rules, path: "firewall/access_rules/rules")
		end
		
		def logs
			self.with(Logs::Received, path: "logs/received")
		end
		
		DEFAULT_PURGE_CACHE_PARAMETERS = {
			purge_everything: true
		}.freeze
		
		def purge_cache(**options)
			if options.empty?
				options = DEFAULT_PURGE_CACHE_PARAMETERS
			end
			
			self.class.post(@resource.with(path: "purge_cache"), options)
		end
		
		def name
			result[:name]
		end
		
		alias to_s name
	end
	
	class Zones < Representation
		include Paginate
		
		def representation
			Zone
		end

		def create(name, account, jump_start: false, **options)
			payload = {name: name, account: account.to_id, jump_start: jump_start, **options}
			
			Zone.post(@resource, payload) do |resource, response|
				value = response.read
				result = value[:result]
				metadata = response.headers
				
				if id = result[:id]
					resource = resource.with(path: id)
				end
				
				Zone.new(resource, value: value, metadata: metadata)
			end
		end
		
		def find_by_name(name)
			each(name: name).find{|zone| zone.name == name}
		end
	end
end
