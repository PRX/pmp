# -*- encoding: utf-8 -*-

require 'oauth2'

module PMP
  class Credential

    include Configuration
    include Connection

    CREDENTIAL_PARAMS = [:scope, :token_expires_in, :label]

    attr_accessor :root

    def initialize(options={}, &block)
      apply_configuration(options)

      self.root = current_options.delete(:root)

      yield(self) if block_given?
    end

    def list
      response = request(:get, credentials_url)
      response.body
    end

    def create(params={})
      response = request(:post, create_credentials_url, create_params(params))
      response.body
    end

    def destroy(client_id)
      response = request(:delete, remove_credentials_url(client_id))
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

      conn_opts = current_options.merge({headers: headers, basic_auth: true})

      raw = connection(conn_opts).send(method, url, body)
      PMP::Response.new(raw, {method: method, url: url, body: body})
    end

    def credentials_url
      root.auth['urn:collectiondoc:form:listcredentials'].url
    end

    def create_credentials_url
      root.auth['urn:collectiondoc:form:createcredentials'].url
    end

    def remove_credentials_url(client_id)
      link = root.auth['urn:collectiondoc:form:removecredentials']
      link.where(client_id: client_id).url
    end

    def root
      @root ||= PMP::CollectionDocument.new(current_options.merge(href: endpoint))
    end

  end
end
