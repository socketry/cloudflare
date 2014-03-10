require 'test/unit'
require 'cloudflare'

class HostTest < Test::Unit::TestCase
	def test_client_connection
		cf = CloudFlare::connection('example_api', 'example@example.com')
		
		info = assert_raise CloudFlare::RequestError, "as" do
			cf.ipv46('example.com', true)
		end

		assert info, 'No or invalid host_key.'
	end

	def test_host_connection
		cf = CloudFlare::connection('example_api')

		info = assert_raise CloudFlare::RequestError do 
			cf.user_auth('example.com', 'password')
		end

		assert info, 'No or invalid host_key.'
	end
end
