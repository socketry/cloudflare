# frozen_string_literal: true

require_relative 'custom_hostname/ssl_params'
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

    def ssl
      @ssl ||= SSLParams.new(value[:ssl])
    end

    def update_settings(metadata: nil, origin: nil, ssl_settings: nil)
      attrs = { ssl: ssl.to_h }
      attrs[:ssl][:settings].merge!(ssl_settings) if ssl_settings
      attrs[:custom_metadata] = metadata if metadata
      attrs[:custom_origin_server] = origin if origin

      response = patch(attrs)

      @ssl = nil # Kill off our cached version of the ssl object so it will be regenerated from the response
      @value = response.result
    end

    alias :to_s :hostname

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

      message = self.post(attrs)
      represent(message.headers, message.result)
    end

    def find_by_hostname(hostname)
      each(hostname: hostname).first
    end

    def find_by_ssl_state(enabled: true)
      each(ssl: enabled ? 1 : 0).first
    end

  end

end
