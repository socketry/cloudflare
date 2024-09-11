# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2017-2024, by Samuel Williams.
# Copyright, 2018, by Leonhardt Wille.
# Copyright, 2019, by Rob Widmer.

require "json"

require "async/rest/representation"
require "async/rest/wrapper/json"

module Cloudflare
	class RequestError < StandardError
		def initialize(resource, errors)
			super("#{resource}: #{errors.map{|attributes| attributes[:message]}.join(', ')}")
			
			@representation = representation
		end
		
		attr_reader :representation
	end
	
	class Wrapper < Async::REST::Wrapper::JSON
	end
	
	class Representation < Async::REST::Representation
		WRAPPER = Wrapper.new
		
		def initialize(...)
			super(...)
			
			# Some endpoints return the value instead of a message object (like KV reads)
			unless @value.is_a?(Hash)
				@value = {success: true, result: @value}
			end
		end
		
		def representation
			Representation
		end
		
		def represent(metadata, attributes)
			resource = @resource.with(path: attributes[:id])
			
			representation.new(resource, metadata: metadata, value: attributes)
		end
		
		def represent_message(message)
			represent(message.headers, message.result)
		end
		
		def to_hash
			if value.is_a?(Hash)
				return value
			end
		end
		
		def result
			value[:result]
		end
		
		def read
			value[:result]
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
