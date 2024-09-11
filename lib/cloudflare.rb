# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2012-2016, by Marcin Prokop.
# Copyright, 2013, by emckay.
# Copyright, 2014, by Jason Green.
# Copyright, 2014-2019, by Samuel Williams.
# Copyright, 2014, by Greg Retkowski.
# Copyright, 2018, by Leonhardt Wille.
# Copyright, 2019, by Akinori MUSHA.

require "async"
require_relative "cloudflare/connection"

module Cloudflare
	DEFAULT_ENDPOINT = Async::HTTP::Endpoint.parse("https://api.cloudflare.com/client/v4/")
	
	def self.connect(endpoint = DEFAULT_ENDPOINT, **auth_info)
		representation = Connection.for(endpoint)
		
		if !auth_info.empty?
			representation = representation.authenticated(**auth_info)
		end
		
		return representation unless block_given?
		
		Async do
			begin
				yield representation
			ensure
				representation.close
			end
		end
	end
end
