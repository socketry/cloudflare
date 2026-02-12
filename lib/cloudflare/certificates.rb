# frozen_string_literal: true

require_relative "representation"
require_relative "paginate"

module Cloudflare
	class Certificate < Representation
		def certificate
			result[:certificate]
		end
	end
	
	class Certificates < Representation
		include Paginate
		
		def representation
			Certificate
		end
		
		def create(csr_pem, hostnames, request_type = "origin-rsa", requested_validity = 5475)
			represent_message(self.post({
				csr: csr_pem,
				request_type: request_type,
				hostnames: hostnames,
				requested_validity: requested_validity
			}))
		end
	end
end
