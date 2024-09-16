# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2024, by Samuel Williams.

require "cloudflare/logs"
require "cloudflare/a_connection"

describe Cloudflare::Logs do
	include_context Cloudflare::AConnection
	
	# it "can list logs" do
	# 	logs = zone.logs.first(10)
		
	# 	expect(logs).not.to be(:empty?)
	# end
end
