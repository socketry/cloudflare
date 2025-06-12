# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2025, by Ivan Vergés.

require "digest"
require_relative "paginate"
require_relative "representation"

module Cloudflare
  class Token < Representation
    include Async::REST::Representation::Mutable

    def name
      result[:name]
    end

    def id
      result[:id]
    end

    def secret
      Digest::SHA2.hexdigest(result[:value])
    end

    def delete
      self.class.delete(@resource.with(path: name)) do |resource, response|
        response.success?
      end
    end
  end

  class Tokens < Representation
    include Paginate

    def representation
      Token
    end

    def result
      value[:result]
    end

    def create(name, **options)
      payload = {name: name, **options}
      self.class.post(@resource, payload) do |resource, response|
        value = response.read

        Token.new(resource, value: value, metadata: response.headers)
      end
    end

    def find_by_name(name)
      each.find {|token| token.name == name }
    end
  end
end