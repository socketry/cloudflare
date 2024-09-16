# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2024, by Samuel Williams.

require "cloudflare/accounts"
require "cloudflare/a_connection"

describe Cloudflare::Connection do
	include_context Cloudflare::AConnection
	
	with "#user" do
		it "can get the current user" do
			user = connection.user
			
			expect(user).to have_attributes(
				id: be =~ /\A[a-f0-9]{32}\z/,
			)
		end
	end
end
