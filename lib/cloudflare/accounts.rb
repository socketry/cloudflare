# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2018-2024, by Samuel Williams.
# Copyright, 2019, by Rob Widmer.

require_relative "representation"
require_relative "paginate"
require_relative "kv/namespaces"

module Cloudflare
	class Account < Representation
		def id
			result[:id]
		end

		def kv_namespaces
			self.with(KV::Namespaces, path: "storage/kv/namespaces")
		end
	end

	class Accounts < Representation
		include Paginate

		def representation
			Account
		end
	end
end
