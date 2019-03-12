# frozen_string_literal: true

# This implements the Custom Hostname API
# https://api.cloudflare.com/#custom-hostname-for-a-zone-properties

require_relative 'custom_hostname/ssl_attribute'
require_relative 'paginate'
require_relative 'representation'

module Cloudflare

  class CustomHostname < Representation

    # Only available if enabled for your zone
    def custom_origin
      value[:custom_origin_server]
    end

    # Only available if enabled for your zone
    def custom_metadata
      value[:custom_metadata]
    end

    def hostname
      value[:hostname]
    end

    def id
      value[:id]
    end

    def ssl
      @ssl ||= SSLAttribute.new(value[:ssl])
    end

    # Check if the cert has been validated
    # passing true will send a request to Cloudflare to try to validate the cert
    def ssl_active?(force_update = false)
      send_patch(ssl: { method: ssl.method, type: ssl.type }) if force_update && ssl.pending_validation?
      ssl.active?
    end

    def update_settings(metadata: nil, origin: nil, ssl: nil)
      attrs = {}
      attrs[:custom_metadata] = metadata if metadata
      attrs[:custom_origin_server] = origin if origin
      attrs[:ssl] = ssl if ssl

      send_patch(attrs)
    end

    alias :to_s :hostname

    private

    def send_patch(data)
      response = patch(data)

      @ssl = nil # Kill off our cached version of the ssl object so it will be regenerated from the response
      @value = response.result
    end

  end

  class CustomHostnames < Representation
    include Paginate

    def representation
      CustomHostname
    end

    # initializes a custom hostname object and yields it for customization before saving
    def create(hostname, metadata: nil, origin: nil, ssl: {}, &block)
      attrs = { hostname: hostname, ssl: { method: 'http', type: 'dv' }.merge(ssl) }
      attrs[:custom_metadata] = metadata if metadata
      attrs[:custom_origin_server] = origin if origin

      represent_message(self.post(attrs))
    end

    def find_by_hostname(hostname)
      each(hostname: hostname).first
    end

  end

end
