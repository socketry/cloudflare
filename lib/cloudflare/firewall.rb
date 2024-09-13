# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2019-2024, by Samuel Williams.
# Copyright, 2019, by Rob Widmer.

require_relative "representation"
require_relative "paginate"

module Cloudflare
	module Firewall
		class Rule < Representation
			include Async::REST::Representation::Mutable
			
			def mode
				result[:mode]
			end
			
			def notes
				result[:notes]
			end
			
			def configuration
				result[:configuration]
			end
			
			def to_s
				"#{configuration[:value]} - #{mode} - #{notes}"
			end
		end

		class Rules < Representation
			include Paginate
			
			def representation
				Rule
			end
			
			def set(mode, value, notes: nil, target: "ip")
				notes ||= "cloudflare gem [#{mode}] #{Time.now.strftime('%m/%d/%y')}"
				
				payload = {mode: mode.to_s, notes: notes, configuration: {target: target, value: value.to_s}}
				
				Rule.post(@resource, payload) do |resource, response|
					value = response.read
					result = value[:result]
					metadata = response.headers
					
					if id = result[:id]
						resource = resource.with(path: id)
					end
					
					Rule.new(resource, value: value, metadata: metadata)
				end
			end
			
			def each_by_value(value, &block)
				each(configuration_value: value, &block)
			end
		end
	end
end
