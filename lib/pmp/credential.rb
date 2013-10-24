# -*- encoding: utf-8 -*-

require 'oauth2'

module PMP
  class Credential

    include Configuration
    include Connection

    CREDENTIAL_PARAMS = [:scope, :token_expires_in, :label]

    def initialize(options={}, &block)
      apply_configuration(options)

      yield(self) if block_given?
    end

    def list
      response = request(:get, credentials_url)
      response.body
    end

    def create(params={})
      response = request(:post, credentials_url, create_params(params))
      response.body
    end

    def create_params(params={})
      HashWithIndifferentAccess.new({
        scope: 'read',
        token_expires_in: 60*60*24*30,
        label: "#{user}: #{Time.now}"
      }).merge(params.select{|k,v| CREDENTIAL_PARAMS.include?(k.to_sym)})
    end

    def request(method, url, body={}) # :nodoc:

      headers = {
        'Accept' => "*/*",
        'Content-Type' => [:put, :post].include?(method) ? "application/x-www-form-urlencoded" : nil
      }

      conn_opts = options.merge({headers: headers, basic_auth: true})

      raw = connection(conn_opts).send(method, url, body)
      PMP::Response.new(raw, {method: method, url: url, body: body})
    end

    def credentials_url
      "#{endpoint}auth/credentials"
    end

  end
end
