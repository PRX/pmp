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

    # document is the original json derived doc used to create this resource
    # assumption is that doc is a parsed json doc confirming to collection.doc+json
    # TODO: check if this is a json string or hash, for now assume it has been mashified
    def initialize(options={}, &block)
      super()

      self.href     = options.delete(:href)

      # if there is a doc to be had, pull it out
      self.response = options.delete(:response)
      self.original = options.delete(:document)

      apply_configuration(options)

      if !loaded? && !href
        self.href = endpoint
      end

      yield(self) if block_given?
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
      if !loaded?
        self.response = request(:get, self.href) 
        self.loaded = true
      end
    end

    def loaded?
      !!self.loaded
    end

    # url includes any params - full url
    def request(method, url, body=nil) # :nodoc:
      opts = options
      raw = connection(options.merge({url: url})).send(method) do |request|
        if [:post, :put].include?(method.to_sym) && !body.blank?
          request.body = body.is_a?(String) ? body : body.to_json
        end
      end

      # may not need this, but remember how we made this response
      PMP::Response.new(raw, {method: method, url: url, body: body})
    end

    def method_missing(method, *args)
      begin
        super
      rescue NoMethodError => err
        raise err if loaded?
        load
        self.send(method, *args)
      end
    end

  end
end
