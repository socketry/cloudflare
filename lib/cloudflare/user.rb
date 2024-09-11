# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2017-2019, by Samuel Williams.
# Copyright, 2018, by Leonhardt Wille.

require_relative "representation"

module Cloudflare
	class User < Representation
		def id
			value[:id]
		end
		
		def email
			value[:email]
		end
	end
end
