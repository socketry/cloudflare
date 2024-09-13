# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2019, by Rob Widmer.
# Copyright, 2019-2024, by Samuel Williams.

require_relative "../../representation"

module Cloudflare
	class CustomHostname < Representation
		class SSLAttribute
			class Settings
				def initialize(settings = {})
					@settings = settings
				end

				def ciphers
					@settings[:ciphers]
				end

				def ciphers=(value)
					@settings[:ciphers] = value
				end

				# This will return the raw value, it is needed because
				# if a value is nil we can't assume that it means it is off
				def http2
					@settings[:http2]
				end

				# Always coerce into a boolean, if the key is not
				# provided, this value may not be accurate
				def http2?
					http2 == "on"
				end

				def http2=(value)
					process_boolean(:http2, value)
				end

				def min_tls_version
					@settings[:min_tls_version]
				end

				def min_tls_version=(value)
					@settings[:min_tls_version] = value
				end

				# This will return the raw value, it is needed because
				# if a value is nil we can't assume that it means it is off
				def tls_1_3
					@settings[:tls_1_3]
				end

				# Always coerce into a boolean, if the key is not
				# provided, this value may not be accurate
				def tls_1_3?
					tls_1_3 == "on"
				end

				def tls_1_3=(value)
					process_boolean(:tls_1_3, value)
				end

				private

				def process_boolean(key, value)
					if value.nil?
						@settings.delete(key)
					else
						@settings[key] = !value || value == "off" ? "off" : "on"
					end
				end
			end
		end
	end
end
