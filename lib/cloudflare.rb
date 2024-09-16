# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2012-2016, by Marcin Prokop.
# Copyright, 2013, by Eric McKay.
# Copyright, 2014, by Jason Green.
# Copyright, 2014-2024, by Samuel Williams.
# Copyright, 2014, by Greg Retkowski.
# Copyright, 2018, by Leonhardt Wille.
# Copyright, 2019, by Akinori Musha.

require "async"
require_relative "cloudflare/connection"

module Cloudflare
	def self.connect(*arguments, **auth_info)
		connection = Connection.open(*arguments)
		
		if !auth_info.empty?
			connection = connection.authenticated(**auth_info)
		end
		
		return connection unless block_given?
		
		Sync do
			yield connection
		ensure
			connection.close
		end
	end
end
