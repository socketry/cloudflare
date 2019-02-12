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

module Cloudflare
	module Paginate
		include Enumerable

		def each(page: 1, per_page: 50, **parameters)
			return to_enum(:each, page: page, per_page: per_page, **parameters) unless block_given?

			while true
				zones = @resource.get(self.class, page: page, per_page: per_page, **parameters)

				break if zones.empty?

				Array(zones.value).each do |attributes|
					resource = @resource.with(path: attributes[:id])

					yield representation.new(resource, metadata: zones.metadata, value: attributes)
				end

				page += 1

				# Was this the last page?
				break if zones.value.count < per_page
			end
		end

		def empty?
			self.value.empty?
		end

		def find_by_id(id)
			representation.new(@resource.with(path: id))
		end
	end
end
