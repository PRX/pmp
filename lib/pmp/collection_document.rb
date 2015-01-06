require 'ostruct'
require 'uri'

module PMP

  # Using OpenStruct for now - perhaps use ActiveModel? hmm...
  class CollectionDocument

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

    # private var to save attributes obj, to handle object attributes
    attr_accessor :attributes

    # private var to save links obj, to handle link additions
    attr_accessor :links

    # this is a tricky, read-only list of items, same as if loaded from link->item links
    # do not put into json form of this doc
    attr_accessor :items

    # document is the original json derived doc used to create this resource
    # assumption is that doc is a parsed json doc confirming to collection.doc+json
    # TODO: check if this is a json string or hash, for now assume it has been mashified
    def initialize(options={}, &block)
      @mutex = Mutex.new

      apply_configuration(options)

      self.root       = current_options.delete(:root)
      self.href       = current_options.delete(:href)
      self.version    = current_options.delete(:version) || '1.0'

      self.attributes = OpenStruct.new

      # if there is a doc to be had, pull it out
      self.response   = current_options.delete(:response)
      self.original   = current_options.delete(:document)

      yield(self) if block_given?
    end

    def items
      get
      @items ||= []
    end

    def attributes
      get
      attributes_object
    end

    def attributes_object
      @attributes || OpenStruct.new
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

    def get
      @mutex.synchronize {
        return self if loaded? || !href
        self.response = request(:get, href)
        self.loaded = true
      }
      self
    end

    def links
      get
      links_object
    end

    def links_object
      @links ||= PMP::Links.new(self)
    end

    def save
      set_guid_if_blank
      url = save_link.where(guid: self.guid).url
      resp = request(:put, url, self)
      self.response = resp
      self.href = resp.body['url']
    end

    def delete
      raise 'No guid specified to delete' if self.guid.blank?

      url = delete_link.where(guid: self.guid).url
      request(:delete, url)
    end

    def save_link
      link = root.edit['urn:collectiondoc:form:documentsave']
      raise 'Save link not found' unless link
      link
    end

    def delete_link
      link = root.edit['urn:collectiondoc:form:documentdelete']
      raise 'Delete link not found' unless link
      link
    end

    def root=(r)
      @root = r
    end

    def root
      @root ||= new_root
    end

    def new_root
      root_options = current_options.merge(href: endpoint)
      PMP::CollectionDocument.new(root_options).tap{|r| r.root = r }
    end

    def loaded?
      !!self.loaded
    end

    def setup_oauth_token
      if !oauth_token && current_options[:client_id] && current_options[:client_secret]
        token = PMP::Token.new(current_options.merge(root: root)).get_token
        self.oauth_token = token.token
        self.token_type  = token.params['token_type']

        if @root
          @root.oauth_token = token.token
          @root.token_type  = token.params['token_type']
        end

      end
    end

    # url includes any params - full url
    def request(method, url, body=nil) # :nodoc:

      unless ['/', ''].include?(URI::parse(url).path)
        setup_oauth_token
      end

      begin
        raw = connection(current_options.merge({url: url})).send(method) do |req|
          if [:post, :put].include?(method.to_sym) && !body.blank?
            req.body = PMP::CollectionDocument.to_persist_json(body)
          end
        end
      rescue Faraday::Error::ResourceNotFound => not_found_ex
        if (method.to_sym == :get)
          raw = OpenStruct.new(body: nil, status: 404)
        else
          raise not_found_ex
        end
      end

      # may not need this, but remember how we made this response
      PMP::Response.new(raw, {method: method, url: url, body: body})
    end

    # static method to filter out static parts of c.doc+j hash before PUT/POST to PMP server
    # in the future this should be fixed in PMP API to no longer be necessary
    def self.to_persist_json(body)
      return body.to_s if body.is_a?(String) || !body.respond_to?(:as_json)

      result = body.as_json.select { |k,v| %w(version attributes links).include?(k) }
      result['attributes'].reject! { |k,v| %w(created modified).include?(k) }
      result['links'].reject! { |k,v| %w(creator query edit auth).include?(k) }

      result.to_json
    end

    def attributes_map
      HashWithIndifferentAccess.new(attributes.marshal_dump)
    end

    def set_guid_if_blank
      self.guid = SecureRandom.uuid if guid.blank?
    end

    def method_missing(method, *args)
      get if (method.to_s.last != '=')
      respond_to?(method) ? send(method, *args) : attributes_object.send(method, *args)
    end

  end
end
