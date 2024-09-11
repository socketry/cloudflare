# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2019-2024, by Samuel Williams.
# Copyright, 2019, by Rob Widmer.
# Copyright, 2019, by David Wegman.

require_relative "representation"
require_relative "paginate"

module Cloudflare
	module DNS
		class Record < Representation
			def initialize(url, record = nil, **options)
				super(url, **options)

				@record = record || get.result
			end

			def update_content(content, **options)
				response = put(
					type: @record[:type],
					name: @record[:name],
					content: content,
					**options
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

			def proxied
				value[:proxied]
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
				represent_message(self.post(type: type, name: name, content: content, **options))
			end

			def find_by_name(name)
				each(name: name).first
			end
		end
	end
end
