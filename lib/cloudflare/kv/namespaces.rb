# frozen_string_literal: true

# This implements the Worker KV Store API
# https://api.cloudflare.com/#workers-kv-namespace-properties

require_relative '../paginate'
require_relative '../representation'

module Cloudflare
  module KV

    class Key < Representation

      def name
        value[:name]
      end

    end

    class Keys < Representation
      include Paginate

      def representation
        Key
      end

    end

    class Namespace < Representation

      def delete_value(name)
        value_representation(name).delete.success?
      end

      def id
        value[:id]
      end

      def keys
        Keys.new(@resource.with(path: 'keys'))
      end

      def read_value(name)
        value_representation(name).value
      end

      def rename(new_title)
        put(title: new_title)
        value[:title] = new_title
      end

      def title
        value[:title]
      end

      def write_value(name, value)
        value_representation(name).put(value).success?
      end

      private

      def value_representation(name)
        Representation.new(@resource.with(path: "values/#{name}"))
      end

    end

    class Namespaces < Representation
      include Paginate

      def representation
        Namespace
      end

      def create(title)
        represent_message(post(title: title))
      end

      def find_by_title(title)
        each.find {|ns| ns.title == title }
      end

    end
  end
end
