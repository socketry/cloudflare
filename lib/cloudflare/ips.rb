# frozen_string_literal: true

require_relative "representation"

module Cloudflare
	class IPs < Representation
		def cidrs(ipv: nil)
			if ipv
				result[:"ipv#{ipv}_cidrs"]
			else
				result[:ipv4_cidrs].to_a + result[:ipv6_cidrs].to_a
			end
		end
	end
end
