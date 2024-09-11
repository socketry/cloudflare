# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2019, by Samuel Williams.
# Copyright, 2019, by Rob Widmer.

require_relative "representation"
require_relative "paginate"

module Cloudflare
	module Firewall
		class Rule < Representation
			def mode
				value[:mode]
			end

			def notes
				value[:notes]
			end

			def configuration
				value[:configuration]
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

				message = self.post({
					mode: mode.to_s,
					notes: notes,
					configuration: {
						target: target,
						value: value.to_s,
					}
				})

				represent_message(message)
			end

			def each_by_value(value, &block)
				each(configuration_value: value, &block)
			end
		end
	end
end
