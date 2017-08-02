# Copyright, 2012, by Marcin Prokop.
# Copyright, 2017, by Samuel G. D. Williams. <http://www.codeotaku.com>
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

require 'net/http'
require 'json'

require 'rest-client'

require_relative 'response'

module Cloudflare
	DEFAULT_URL = "https://api.cloudflare.com/client/v4/"
	TIMEOUT = 10 # Default is 5 seconds

	class Resource < RestClient::Resource
    include Enumerable
		# @param api_key [String] `X-Auth-Key` or `X-Auth-User-Service-Key` if no email provided.
		# @param email [String] `X-Auth-Email`, your email address for the account.
		def initialize(url = DEFAULT_URL, key: nil, email: nil, **options)
			headers = options[:headers] || {}

			if email.nil?
				headers['X-Auth-User-Service-Key'] = key
			else
				headers['X-Auth-Key'] = key
				headers['X-Auth-Email'] = email
			end

			# Convert HTTP API responses to our own internal response class:
			super(url, headers: headers, accept: 'application/json', **options) do |response|
				Response.new(response.request.url, response.body)
			end
		end

    def paginate(obj, url, url_args = "")
			page = 1
			page_size = 100
			results = []

			loop do  # fetch and aggregate all pages
				rules = obj.new(concat_urls(url, "?scope_type=organization#{url_args}&per_page=#{page_size}&page=#{page}"), self, **options)
				results += rules.get.results
				break if results.size % page_size != 0
				page += 1
			end
			results
	end


	end

	class Connection < Resource
	end
end
