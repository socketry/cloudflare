# frozen_string_literal: true

# Copyright, 2012, by Marcin Prokop.
# Copyright, 2017, by Samuel G. D. Williams. <http://www.codeotaku.com>
# Copyright, 2017, by David Rosenbloom. <http://artifactory.com>
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

require_relative 'representation'
require_relative 'paginate'

require_relative 'firewall'
require_relative 'dns'
require_relative 'logs'

module Cloudflare
	class Zone < Representation
		def dns_records
			DNS::Records.new(@resource.with(path: 'dns_records'))
		end
		
		def firewall_rules
			Firewall::Rules.new(@resource.with(path: 'firewall/access_rules/rules'))
		end
		
		def logs
			Logs::Received.new(@resource.with(path: 'logs/received'))
		end
		
		DEFAULT_PURGE_CACHE_PARAMS = {
			purge_everything: true
		}.freeze
		
		def purge_cache(parameters = DEFAULT_PURGE_CACHE_PARAMS)
			Zone.new(@resource.with(path: 'purge_cache')).post(parameters)
			self
		end
		
		def name
			value[:name]
		end
		
		alias to_s name
	end
	
	class Zones < Representation
		include Paginate
		
		def representation
			Zone
		end
		
		def create(name, account, jump_start = false)
			message = self.post(name: name, account: account.to_hash, jump_start: jump_start)
			
			id = message.result[:id]
			resource = @resource.with(path: id)
			
			return representation.new(resource, metadata: message.headers, value: message.result)
		end
		
		def find_by_name(name)
			each(name: name).first
		end

		def find_by_id(id)
			Zone.new(@resource.with(path: id))
		end
	end
end
