# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2018-2024, by Samuel Williams.
# Copyright, 2019, by Rob Widmer.

module Cloudflare
	module Paginate
		include Enumerable
		
		def each(page: 1, per_page: 50, **parameters)
			return to_enum(:each, page: page, per_page: per_page, **parameters) unless block_given?
			
			while true
				resource = @resource.with(parameters: {page: page, per_page: per_page, **parameters})
				
				response = self.class.get(resource)
				
				break if response.empty?
				
				response.results.each do |attributes|
					yield represent(response.metadata, attributes)
				end
				
				page += 1
				
				# Was this the last page?
				break if response.results.size < per_page
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
