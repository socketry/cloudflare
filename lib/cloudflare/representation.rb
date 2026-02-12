# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2017-2024, by Samuel Williams.
# Copyright, 2018, by Leonhardt Wille.
# Copyright, 2019, by Rob Widmer.

require "json"

require "async/rest/representation"
require "async/rest/wrapper/json"

require_relative "request_error"

module Cloudflare
	class Wrapper < Async::REST::Wrapper::JSON
		def process_response(request, response)
			super
			
			if response.failure?
				raise RequestError.new(request, response.read)
			end
		end
	end
	
	class Representation < Async::REST::Representation
		WRAPPER = Wrapper.new
		
		def representation
			Representation
		end
		
		def represent(metadata, attributes)
			resource = @resource.with(path: attributes[:id])
			
			representation.new(resource, metadata: metadata, value: {
				success: true, result: attributes
			})
		end
		
		def represent_message(message)
			represent(message.headers, message.result)
		end
		
		def result
			value[:result]
		end
		
		def to_hash
			result
		end
		
		def to_id
			{id: result[:id]}
		end
		
		def results
			Array(result)
		end
		
		def errors
			value[:errors]
		end
		
		def messages
			value[:messages]
		end
		
		def success?
			value[:success]
		end
	end
end
