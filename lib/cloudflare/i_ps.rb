require_relative 'representation'

module Cloudflare
	class IPs < Representation
    def cidrs(ipv: nil)
      if ipv
        value[:"ipv#{ipv}_cidrs"]
      else
        value[:ipv4_cidrs].to_a + value[:ipv6_cidrs].to_a
      end
		end
	end
end
