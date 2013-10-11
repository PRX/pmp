# -*- encoding: utf-8 -*-
require 'oauth2'

module PMP
  class Token

    include Configuration

    def initialize(options={}, &block)
      apply_configuration(options)

      yield(self) if block_given?
    end

    def token_url
      options['token_url'] || '/auth/access_token'
    end

    def get_token
      oauth_options = {
        site:            endpoint,
        token_url:       token_url,
        connection_opts: connection_options(options)
      }

      client = OAuth2::Client.new(client_id, client_secret, oauth_options) do |faraday|
        faraday.request  :url_encoded
        faraday.response :logger if debug
        faraday.adapter  adapter
      end

      client.client_credentials.get_token
    end

    def connection_options(opts={})
      headers = opts.delete(:headers) || {}
      options = {
        :headers => {
          'User-Agent'   => opts[:user_agent],
          'Accept'       => 'application/json',
          'Content-Type' => 'application/x-www-form-urlencoded'
        },
        :ssl => {:verify => false},
        :url => opts[:endpoint]
      }.merge(opts)
      options[:headers] = options[:headers].merge(headers)

      options
    end

  end
end
