# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2025, by Ivan Vergés.

require_relative "../paginate"
require_relative "../representation"
require_relative "domains"
require_relative "cors"

module Cloudflare
	module R2
		class Bucket < Representation
			include Async::REST::Representation::Mutable

			def name
				result[:name]
			end

			def domains
				self.with(Domains, path: "#{name}/domains/custom")
			end

			def cors
				self.with(Cors, path: "#{name}/cors")
			end

			def create_cors(**options)
				payload = { bucket_name: name, **options}
				self.class.put(@resource.with(path: "#{name}/cors"), payload) do |resource, response|
					if response.success?
						cors
					else
						raise RequestError.new(resource, response.read)
					end
				end
			end

			def delete
				self.class.delete(@resource.with(path: name)) do |resource, response|
					response.success?
				end
			end
		end

		class Buckets < Representation
			include Paginate

			def representation
				Bucket
			end

			def result
				value[:result][:buckets]
			end

			def create(name, **options)
				payload = {name: name, **options}
				self.class.post(@resource, payload) do |resource, response|
					value = response.read

					Bucket.new(resource, value: value, metadata: response.headers)
				end
			end

			def find_by_name(name)
				each.find {|bucket| bucket.name == name }
			end
		end
	end
end