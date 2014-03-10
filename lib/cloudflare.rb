require 'cloudflare/connection'

module CloudFlare
	def self.connection(api_key, email = nil)
		Connection.new(api_key, email = nil)
	end
end
