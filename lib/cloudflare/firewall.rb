# frozen_string_literal: true

# Copyright, 2018, by Samuel G. D. Williams. <http://www.codeotaku.com>
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

module Cloudflare
	module Firewall
		class Rule < Representation
			def mode
				value[:mode]
			end
			
			def notes
				value[:notes]
			end
			
			def configuration
				value[:configuration]
			end
			
			def to_s
				"#{configuration[:value]} - #{mode} - #{notes}"
			end
		end

		class Rules < Representation
			include Paginate
			
			def representation
				Rule
			end
			
			def where(mode: nil, ip: nil, notes: nil)
				filter = {}
				
				filter[:mode] = mode if mode
				filter[:configuration_value] = ip if ip
				filter[:notes] = nodes if notes
				
				self.class.new(@resource.with(parameters: filter))
			end

			def ips(mode: 'block')
				self.where(mode: mode).collect{|r| r.record[:configuration][:value]}
			end
			
			def set(mode, value, notes: nil, target: 'ip')
				notes ||= "cloudflare gem [#{mode}] #{Time.now.strftime('%m/%d/%y')}"
				
				message = self.post({
					mode: mode.to_s,
					notes: notes,
					configuration: {
						target: target,
						value: value.to_s,
					}
				})
				
				id = message.result[:id]
				resource = @resource.with(path: id)
				
				return representation.new(resource, metadata: message.headers, value: message.result)
			end
			
			def find_by_id(id)
				Rule.new(@resource.with(path: id))
			end
			
			def find_by_ip(ip)
				self.class.new(@resource.with(parameters: {configuration_value: ip}))
			end
		end
	end
end
