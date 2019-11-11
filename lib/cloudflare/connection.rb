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

require_relative 'zones'
require_relative 'accounts'
require_relative 'user'

module Cloudflare
	class Connection < Representation
		def authenticated(token: nil, key: nil, email: nil)
			headers = {}
			
			if token
				headers['Authorization'] = "Bearer #{token}"
			elsif key
				if email
					headers['X-Auth-Key'] = key
					headers['X-Auth-Email'] = email
				else
					headers['X-Auth-User-Service-Key'] = key
				end
			end
			
			self.with(headers: headers)
		end
		
		def zones
			self.with(Zones, path: 'zones')
		end
		
		def accounts
			self.with(Accounts, path: 'accounts')
		end
		
		def user
			self.with(User, path: 'user')
		end
	end
end
