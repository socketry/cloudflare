
require 'cloudflare'

RSpec.describe Cloudflare::Connection do
	it "test_client_connection" do
		cf = Cloudflare.connection('example_api', 'example@example.com')
		
		expect do
			cf.ipv46('example.com', true)
		end.to raise_error(Cloudflare::RequestError)
	end
	
	it "test_host_connetion" do
		cf = Cloudflare.connection('example_api')

		expect do
			cf.user_auth('example.com', 'password')
		end.to raise_error(Cloudflare::RequestError)
	end
end
