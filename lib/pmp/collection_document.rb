require 'ostruct'

module PMP

  # Using OpenStruct for now - perhaps use ActiveModel? hmm...
  class CollectionDocument < OpenStruct

    include Configuration
    include Connection
    include Parser

    # the href/url string to retrieve info for this resource
    attr_accessor :href

    # keep a ref to response obj if this resulted from one
    # should this be private?
    attr_accessor :response

    # keep a ref to original doc from which this obj was created
    # should this be private?
    attr_accessor :original

    # all collection docs have a version
    # default is '1.0'
    attr_accessor :version

    # has this resource actually been loaded from remote url or json document?
    attr_accessor :loaded

    # private var to save links obj, to handle link additions
    attr_accessor :links

    # this is a tricky, read-only list of items, same as if loaded from link->item links
    # do not put into json form of this doc
    attr_accessor :items

    # document is the original json derived doc used to create this resource
    # assumption is that doc is a parsed json doc confirming to collection.doc+json
    # TODO: check if this is a json string or hash, for now assume it has been mashified
    def initialize(options={}, &block)
      super()
      apply_configuration(options)

      self.root     = current_options.delete(:root)
      self.href     = current_options.delete(:href)
      self.version  = current_options.delete(:version) || '1.0'

      self.links    = PMP::Links.new(self)

      # if there is a doc to be had, pull it out
      self.response = current_options.delete(:response)
      self.original = current_options.delete(:document)

      yield(self) if block_given?
    end

    def items
      load
      @items ||= []
    end

    def attributes
      HashWithIndifferentAccess.new(marshal_dump.delete_if{|k,v| links.keys.include?(k.to_s)})
    end

    def response=(resp)
      unless (!resp || loaded?)
        @response = resp
        self.original = resp.body
      end
    end

    def original=(doc)
      unless (!doc || loaded?)
        @original = doc
        parse(@original)
        self.loaded = true
      end
    end

    def load
      if !loaded? && href
        self.response = request(:get, href)
        self.loaded = true
      end
    end
    alias_method :get, :load

    def save
      set_guid_if_blank
      url = edit_link('PUT').where(guid: self.guid).url
      response = request(:put, url, self)
      self.href = response.body['url']
    end

    def delete
      raise 'No guid specified to delete' if self.guid.blank?

      url = edit_link('DELETE').where(guid: self.guid).url
      request(:delete, url)
    end

    def edit_link(method)
      link = root_document.edit['urn:collectiondoc:form:documentsave']
      raise "Edit link does not specify saving via #{method}" unless (link && link.hints.allow.include?(method))
      link
    end

    def root
      @root
    end

    def root=(r)
      @root
    end

    def root_document
      @root ||= PMP::CollectionDocument.new(current_options.merge(href: endpoint))
    end

    def loaded?
      !!self.loaded
    end

    def setup_oauth_token
      if !oauth_token && current_options[:client_id] && current_options[:client_secret]
        token = PMP::Token.new(current_options).get_token
        self.oauth_token = token.token
        self.token_type  = token.params['token_type']
      end
    end

    # url includes any params - full url
    def request(method, url, body=nil) # :nodoc:

      setup_oauth_token

      begin
        raw = connection(current_options.merge({url: url})).send(method) do |request|
          if [:post, :put].include?(method.to_sym) && !body.blank?
            request.body = body.is_a?(String) ? body : body.to_put_json
          end
        end
      rescue Faraday::Error::ResourceNotFound=>not_found_ex
        if (method.to_sym == :get)
          raw = OpenStruct.new(body: nil, status: 404)
        else
          raise not_found_ex
        end
      end

      # may not need this, but remember how we made this response
      PMP::Response.new(raw, {method: method, url: url, body: body})
    end

    # blacklist what we PUT back to the server
    def as_put_json
      obj = self.as_json.select { |k,v| %w(attributes links).include?(k) }
      obj['attributes'].reject! { |k,v| %w(created modified).include?(k) }
      obj['links'].reject! { |k,v| %w(creator query edit auth).include?(k) }
      obj
    end

    def to_put_json
      as_put_json.to_json
    end

    def set_guid_if_blank
      self.guid = SecureRandom.uuid if guid.blank?
    end

    def method_missing(method, *args)
      if (method.to_s.last != '=') && !loaded?
        load
        return self.send(method, *args) if self.respond_to?(method)
      end

      super
    end

  end
end
