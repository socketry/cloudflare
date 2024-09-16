# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2017-2024, by Samuel Williams.
# Copyright, 2018, by Leonhardt Wille.

require_relative "representation"

module Cloudflare
	class User < Representation
		def id
			result[:id]
		end
		
		def email
			result[:email]
		end
	end
end
