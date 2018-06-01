# frozen_string_literal: true

require 'sinatra/base'

class FakeCloudFlare < Sinatra::Base
  get '/zones/:id/dns_records/?page=1&per_page=50&scope_type=organization' do
    json_response 200, 'get_all_zones.json'
  end

  private

  def json_response(response_code, file_name)
    content_type :json
    status response_code
    File.open(File.dirname(__FILE__) + '/fixtures/' + file_name, 'rb').read
  end
end
