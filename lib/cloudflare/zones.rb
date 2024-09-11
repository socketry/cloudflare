# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2017-2019, by Samuel Williams.
# Copyright, 2017, by Denis Sadomowski.
# Copyright, 2017, by 莫粒.
# Copyright, 2018, by Leonhardt Wille.
# Copyright, 2018, by Michael Kalygin.
# Copyright, 2018, by Sherman K.
# Copyright, 2018, by Kugayama Nana.
# Copyright, 2018, by Casey Lopez.
# Copyright, 2019, by Akinori MUSHA.
# Copyright, 2019, by Rob Widmer.

require_relative "representation"
require_relative "paginate"

require_relative "custom_hostnames"
require_relative "firewall"
require_relative "dns"
require_relative "logs"

module Cloudflare
	class Zone < Representation
		def custom_hostnames
			self.with(CustomHostnames, path: "custom_hostnames/")
		end

		def dns_records
			self.with(DNS::Records, path: "dns_records/")
		end
		
		def firewall_rules
			self.with(Firewall::Rules, path: "firewall/access_rules/rules/")
		end
		
		def logs
			self.with(Logs::Received, path: "logs/received/")
		end
		
		DEFAULT_PURGE_CACHE_PARAMS = {
			purge_everything: true
		}.freeze
		
		def purge_cache(parameters = DEFAULT_PURGE_CACHE_PARAMS)
			self.with(Zone, path: "purge_cache").post(parameters)
			
			return self
		end
		
		def name
			value[:name]
		end
		
		alias to_s name
	end
	
	class Zones < Representation
		include Paginate
		
		def representation
			Zone
		end

		def create(name, account, jump_start = false)
			represent_message(self.post(name: name, account: account.to_hash, jump_start: jump_start))
		end

		def find_by_name(name)
			each(name: name).first
		end
	end
end
