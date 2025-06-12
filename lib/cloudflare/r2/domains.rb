# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2025, by Ivan Vergés.

require_relative "../paginate"
require_relative "../representation"

module Cloudflare
	module R2
		class Domain < Representation
			def name
				result[:domain]
			end
		end

		class Domains < Representation
			include Paginate

			def representation
				R2::Domain
			end

			def result
				value[:result][:domains]
			end

			def attach(domain, **options)
				payload = {domain:, **options}

				self.class.post(@resource, payload) do |resource, response|
					value = response.read

					Domain.new(resource, value: value, metadata: response.headers)
				end
			end

			def find_by_name(name)
				each.find {|domain| domain.name == name }
			end
		end
	end
end