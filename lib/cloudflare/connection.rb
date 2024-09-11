# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2014-2016, by Marcin Prokop.
# Copyright, 2014-2019, by Samuel Williams.
# Copyright, 2015, by Kyle Corbitt.
# Copyright, 2015, by Guillaume Leseur.
# Copyright, 2018, by Leonhardt Wille.
# Copyright, 2018, by Michael Kalygin.
# Copyright, 2018, by Sherman K.
# Copyright, 2019, by Akinori MUSHA.

require_relative "representation"

require_relative "zones"
require_relative "accounts"
require_relative "user"

module Cloudflare
	class Connection < Representation
		def authenticated(token: nil, key: nil, email: nil)
			headers = {}
			
			if token
				headers["Authorization"] = "Bearer #{token}"
			elsif key
				if email
					headers["X-Auth-Key"] = key
					headers["X-Auth-Email"] = email
				else
					headers["X-Auth-User-Service-Key"] = key
				end
			end
			
			self.with(headers: headers)
		end
		
		def zones
			self.with(Zones, path: "zones/")
		end
		
		def accounts
			self.with(Accounts, path: "accounts")
		end
		
		def user
			self.with(User, path: "user")
		end
	end
end
