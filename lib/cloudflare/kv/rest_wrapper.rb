# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2021, by Terry Kerr.
# Copyright, 2024, by Samuel Williams.

require "json"

module Cloudflare
	module KV
		class RESTWrapper < Async::REST::Wrapper::Generic
			APPLICATION_OCTET_STREAM = "application/octet-stream"
			APPLICATION_JSON = "application/json"
			ACCEPT_HEADER = "#{APPLICATION_JSON}, #{APPLICATION_OCTET_STREAM}"

			def prepare_request(payload, headers)
				headers["accept"] ||= ACCEPT_HEADER

				if payload
					headers["content-type"] = APPLICATION_OCTET_STREAM
					::Protocol::HTTP::Body::Buffered.new([payload.to_s])
				end
			end

			def parser_for(response)
				if response.headers["content-type"].start_with?(APPLICATION_OCTET_STREAM)
					OctetParser
				elsif response.headers["content-type"].start_with?(APPLICATION_JSON)
					JsonParser
				else
					Async::REST::Wrapper::Generic::Unsupported
				end
			end

			class OctetParser < ::Protocol::HTTP::Body::Wrapper
				def join
					super
				end
			end

			class JsonParser < ::Protocol::HTTP::Body::Wrapper
				def join
					JSON.parse(super, symbolize_names: true)
				end
			end
		end
	end
end
