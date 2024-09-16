# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2019, by Rob Widmer.
# Copyright, 2019-2024, by Samuel Williams.

require_relative "custom_hostname/ssl_attribute"
require_relative "paginate"
require_relative "representation"

module Cloudflare
	class CustomHostname < Representation
		include Async::REST::Representation::Mutable
		
		# Only available if enabled for your zone
		def custom_origin
			result[:custom_origin_server]
		end
		
		# Only available if enabled for your zone
		def custom_metadata
			result[:custom_metadata]
		end
		
		def hostname
			result[:hostname]
		end
		
		def id
			result[:id]
		end
		
		def ssl
			@ssl ||= SSLAttribute.new(result[:ssl])
		end
		
		# Check if the cert has been validated
		# passing true will send a request to Cloudflare to try to validate the cert
		def ssl_active?(force_update = false)
			if force_update && ssl.pending_validation?
				self.patch(ssl: {method: ssl.method, type: ssl.type})
			end
			
			return ssl.active?
		end
		
		def update_settings(metadata: nil, origin: nil, ssl: nil)
			payload = {}
			
			payload[:custom_metadata] = metadata if metadata
			payload[:custom_origin_server] = origin if origin
			payload[:ssl] = ssl if ssl
			
			self.patch(payload)
		end
		
		alias :to_s :hostname
		
		private
		
		def patch(payload)
			self.class.patch(@resource, payload) do |resource, response|
				value = response.read
				
				if value[:sucess]
					@ssl = nil
					@value = value
				else
					raise RequestError.new(@resource, value)
				end
			end
		end
	end

	class CustomHostnames < Representation
		include Paginate
		
		def representation
			CustomHostname
		end
		
		def create(hostname, metadata: nil, origin: nil, ssl: {}, **options)
			payload = {hostname: hostname, ssl: {method: "http", type: "dv"}.merge(ssl), **options}
			
			payload[:custom_metadata] = metadata if metadata
			payload[:custom_origin_server] = origin if origin
			
			CustomHostname.post(@resource, payload) do |resource, response|
				value = response.read
				result = value[:result]
				metadata = response.headers
				
				if id = result[:id]
					resource = resource.with(path: id)
				end
				
				CustomHostname.new(resource, value: value, metadata: metadata)
			end
		end

		def find_by_hostname(hostname)
			each(hostname: hostname).first
		end
	end
end
