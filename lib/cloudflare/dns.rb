# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2019-2024, by Samuel Williams.
# Copyright, 2019, by Rob Widmer.
# Copyright, 2019, by David Wegman.

require_relative "representation"
require_relative "paginate"

module Cloudflare
	module DNS
		class Record < Representation
			include Async::REST::Representation::Mutable
			
			def update_content(content, **options)
				self.class.put(@resource, {
					type: self.type,
					name: self.name,
					content: content,
					**options
				}) do |resource, response|
					if response.success?
						@value = response.read
						@metadata = response.headers
					else
						raise RequestError.new(resource, response.read)
					end
					
					self
				end
			end
			
			def type
				result[:type]
			end
			
			def name
				result[:name]
			end
			
			def content
				result[:content]
			end
			
			def proxied?
				result[:proxied]
			end
			
			alias proxied proxied?
			
			def to_s
				"#{self.name} #{self.type} #{self.content}"
			end
		end
		
		class Records < Representation
			include Paginate
			
			def representation
				Record
			end
			
			def create(type, name, content, **options)
				payload = {type: type, name: name, content: content, **options}
				
				Record.post(@resource, payload) do |resource, response|
					value = response.read
					result = value[:result]
					metadata = response.headers
					
					if id = result[:id]
						resource = resource.with(path: id)
					end
					
					Record.new(resource, value: value, metadata: metadata)
				end
			end

			def find_by_name(name)
				each(name: name).find{|record| record.name == name}
			end
		end
	end
end
