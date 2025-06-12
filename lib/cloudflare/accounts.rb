# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2018-2024, by Samuel Williams.
# Copyright, 2019, by Rob Widmer.
# Copyright, 2025, by Ivan Vergés.

require_relative "representation"
require_relative "paginate"
require_relative "kv/namespaces"
require_relative "r2/buckets"
require_relative "tokens"

module Cloudflare
	class Account < Representation
		def id
			result[:id]
		end

		def kv_namespaces
			self.with(KV::Namespaces, path: "storage/kv/namespaces")
		end

		def r2_buckets
			self.with(R2::Buckets, path: "r2/buckets")
		end

		def tokens
			self.with(Tokens, path: "tokens")
		end
	end

	class Accounts < Representation
		include Paginate

		def representation
			Account
		end
	end
end
