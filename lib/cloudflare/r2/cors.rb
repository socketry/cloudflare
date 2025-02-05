# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2025, by Ivan Vergés.

require_relative "../paginate"
require_relative "../representation"

module Cloudflare
	module R2
		class Cors < Representation
			include Async::REST::Representation::Mutable

			def rules
				result[:rules]
			end
		end
	end
end