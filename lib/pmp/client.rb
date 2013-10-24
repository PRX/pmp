# -*- encoding: utf-8 -*-

module PMP
  class Client

    include Configuration

    def initialize(options={}, &block)
      apply_configuration(options)
      yield(self) if block_given?
    end

    def credentials(opts={})
      @credentials = nil if (opts != {})
      @credentials ||= PMP::Credential.new(options.merge(opts))
    end

    def token(opts={})
      @token = nil if (opts != {})
      @token ||= PMP::Token.new(options.merge(opts)).get_token
    end

    def root(opts={})
      @root = nil if (opts != {})
      opts = options.merge(href: endpoint).merge(opts)
      @root ||= PMP::CollectionDocument.new(opts)
    end

    def doc_of_type(type, opts={})
      doc = PMP::CollectionDocument.new(options.merge(opts))
      doc.links['profile'] = Link.new(href: profile_href_for_type(type), type: "application/vnd.pmp.collection.doc+json")
      doc
    end

    # private

    def profile_href_for_type(type)
      "#{endpoint}profiles/#{type}"
    end

    # assume you want to make a call on the root doc for stuff it can do
    def method_missing(method, *args)
      self.root.send(method, *args)
    end

  end
end
