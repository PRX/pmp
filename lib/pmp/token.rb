# -*- encoding: utf-8 -*-

require 'oauth2'

module PMP
  class Token

    include Configuration

    attr_accessor :root

    def initialize(options={}, &block)
      apply_configuration(options)

      self.root = current_options.delete(:root)

      yield(self) if block_given?
    end

    def token_url
      root.auth['urn:collectiondoc:form:issuetoken'].url
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
        headers: {
          'User-Agent'   => opts[:user_agent],
          'Accept'       => 'application/json',
          'Content-Type' => 'application/x-www-form-urlencoded'
        },
        ssl: {:verify => false},
        url: opts[:endpoint]
      }.merge(opts)
      options[:headers] = options[:headers].merge(headers)

      # clean out any that don't belong
      options.select{|k,v| PMP::Connection::ALLOWED_CONNECTION_OPTIONS.include?(k.to_sym)}
    end

    def root
      @root ||= PMP::CollectionDocument.new(current_options.merge(href: endpoint))
    end

  end
end
