# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2017-2024, by Samuel Williams.

module Cloudflare
	class RequestError < StandardError
		def self.error_string_for(value)
			if value.is_a?(Hash)
				if error = value[:error]
					return error
				elsif errors = value[:errors]
					return errors.map{|attributes| attributes[:message]}.join(", ")
				end
			end
			
			return value.inspect
		end
		
		def initialize(request, value)
			super("#{request}: #{self.class.error_string_for(value)}")
			
			@value = value
		end
		
		attr :value
	end
end
