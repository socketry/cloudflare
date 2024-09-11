# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2017-2018, by Samuel Williams.
# Copyright, 2018, by Leonhardt Wille.
# Copyright, 2019, by Rob Widmer.

require "json"

require "async/rest/representation"

module Cloudflare
	class RequestError < StandardError
		def initialize(resource, errors)
			super("#{resource}: #{errors.map{|attributes| attributes[:message]}.join(', ')}")

			@representation = representation
		end

		attr_reader :representation
	end

	class Message
		def initialize(response)
			@response = response
			@body = response.read

			# Some endpoints return the value instead of a message object (like KV reads)
			@body = { success: true, result: @body } unless @body.is_a?(Hash)
		end

		attr :response
		attr :body

		def headers
			@response.headers
		end

		def result
			@body[:result]
		end

		def read
			@body[:result]
		end

		def results
			Array(result)
		end

		def errors
			@body[:errors]
		end

		def messages
			@body[:messages]
		end

		def success?
			@body[:success]
		end
	end

	class Representation < Async::REST::Representation
		def process_response(*)
			message = Message.new(super)

			unless message.success?
				raise RequestError.new(@resource, message.errors)
			end

			return message
		end

		def representation
			Representation
		end

		def represent(metadata, attributes)
			resource = @resource.with(path: attributes[:id])
			binding.irb

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
	end
end
