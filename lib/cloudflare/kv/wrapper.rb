# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2021, by Terry Kerr.
# Copyright, 2024, by Samuel Williams.

require "json"

module Cloudflare
	module KV
		class Wrapper < Cloudflare::Wrapper
			APPLICATION_OCTET_STREAM = "application/octet-stream"
			def prepare_request(request, payload)
				request.headers.add("accept", APPLICATION_OCTET_STREAM)
				
				if payload
					request.headers["content-type"] = APPLICATION_OCTET_STREAM
					
					request.body = ::Protocol::HTTP::Body::Buffered.new([payload.to_s])
				end
			end
			
			def parser_for(response)
				if response.headers["content-type"].start_with?(APPLICATION_OCTET_STREAM)
					OctetParser
				else
					super
				end
			end

			class OctetParser < ::Protocol::HTTP::Body::Wrapper
				def join
					super.force_encoding(Encoding::BINARY)
				end
			end
		end
	end
end
