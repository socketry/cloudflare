# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2019, by Rob Widmer.
# Copyright, 2019-2024, by Samuel Williams.
# Copyright, 2021, by Terry Kerr.

require_relative "../paginate"
require_relative "../representation"
require_relative "wrapper"

module Cloudflare
	module KV
		class Key < Representation
			def name
				result[:name]
			end
		end
		
		class Value < Representation[Wrapper]
			include Async::REST::Representation::Mutable
			
			def put(value)
				self.class.put(@resource, value) do |resource, response|
					value = response.read
					
					return value[:success]
				end
			end
		end
		
		class Keys < Representation
			include Paginate
			
			def representation
				Key
			end
		end
		
		class Namespace < Representation
			include Async::REST::Representation::Mutable
			
			def delete_value(name)
				value_representation(name).delete.success?
			end
			
			def id
				result[:id]
			end
			
			def keys
				self.with(Keys, path: "keys")
			end
			
			def read_value(name)
				value_representation(name).value
			end
			
			def rename(new_title)
				self.class.put(@resource, title: new_title) do |resource, response|
					value = response.read
					
					if value[:success]
						result[:title] = new_title
					else
						raise RequestError.new(resource, value)
					end
				end
			end
			
			def title
				result[:title]
			end
			
			def write_value(name, value)
				value_representation(name).put(value)
			end
			
			private
			
			def value_representation(name)
				self.with(Value, path: "values/#{name}/")
			end
		end
		
		class Namespaces < Representation
			include Paginate
			
			def representation
				Namespace
			end
			
			def create(title, **options)
				payload = {title: title, **options}
				
				Namespace.post(@resource, payload) do |resource, response|
					value = response.read
					result = value[:result]
					metadata = response.headers
					
					if id = result[:id]
						resource = resource.with(path: id)
					end
					
					Namespace.new(resource, value: value, metadata: metadata)
				end
			end
			
			def find_by_title(title)
				each.find {|namespace| namespace.title == title }
			end
		end
	end
end
