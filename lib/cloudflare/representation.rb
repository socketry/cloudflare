# frozen_string_literal: true

# Copyright, 2012, by Marcin Prokop.
# Copyright, 2017, by Samuel G. D. Williams. <http://www.codeotaku.com>
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
# THE SOFTWARE.

require 'json'

require 'async/rest/representation'

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

			representation.new(resource, metadata: metadata, value: attributes)
		end

		def to_hash
			if value.is_a?(Hash)
				return value
			end
		end
	end
end
