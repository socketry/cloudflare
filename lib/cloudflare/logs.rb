# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2019-2024, by Samuel Williams.

require_relative "representation"
require_relative "paginate"

module Cloudflare
	module Logs
		class Entry < Representation
			def to_s
				"#{result[:rayid]}-#{result[:ClientRequestURI]}"
			end
		end
	
		class Received < Representation
			include Paginate
			
			def representation
				Entry
			end
		end
	end
end
