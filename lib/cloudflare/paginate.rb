# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2018-2019, by Samuel Williams.
# Copyright, 2019, by Rob Widmer.

module Cloudflare
	module Paginate
		include Enumerable

		def each(page: 1, per_page: 50, **parameters)
			return to_enum(:each, page: page, per_page: per_page, **parameters) unless block_given?

			while true
				zones = @resource.get(self.class, page: page, per_page: per_page, **parameters)

				break if zones.empty?

				Array(zones.value).each do |attributes|
					yield represent(zones.metadata, attributes)
				end

				page += 1

				# Was this the last page?
				break if zones.value.size < per_page
			end
		end

		def empty?
			self.value.empty?
		end

		def find_by_id(id)
			representation.new(@resource.with(path: "#{id}/"))
		end
	end
end
