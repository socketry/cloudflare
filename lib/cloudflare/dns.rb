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

module Cloudflare
	module DNS
		class Record < Representation
			def initialize(url, record = nil, **options)
				super(url, **options)

				@record = record || get.result
			end

			def update_content(content)
				response = put(
					type: @record[:type],
					name: @record[:name],
					content: content
				)
				
				@value = response.result
			end
			
			def type
				value[:type]
			end
			
			def name
				value[:name]
			end
			
			def content
				value[:content]
			end
			
			def to_s
				"#{@record[:name]} #{@record[:type]} #{@record[:content]}"
			end
		end

		class Records < Representation
			include Paginate
			
			def representation
				Record
			end
			
			TTL_AUTO = 1
			
			def create(type, name, content, **options)
				message = self.post(type: type, name: name, content: content, **options)
				
				id = message.result[:id]
				resource = @resource.with(path: id)
				
				return representation.new(resource, metadata: message.headers, value: message.result)
			end
			
			def find_by_name(name)
				self.class.new(@resource.with(parameters: {name: name})).first
			end
			
			def find_by_id(id)
				Record.new(@resource.with(path: id))
			end
		end
	end
end
