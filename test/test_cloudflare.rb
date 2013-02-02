require 'test/unit'
require 'cloudflare'

class HostTest < Test::Unit::TestCase

  def test_client_connection
    cf = CloudFlare.new('example_api', 'example@example.com')
    assert_equal('E_UNAUTH', cf.ipv46('example.com', true)['err_code'])
  end

  def test_host_connection
    cf = CloudFlare.new('example_api')
    assert_equal(100, cf.user_auth('example.com', 'password')['err_code'])
  end

end
