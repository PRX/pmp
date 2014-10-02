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
      @root ||= new_root(opts)
    end

    def new_root(opts={})
      root_options = options.merge(opts).merge(href: endpoint)
      PMP::CollectionDocument.new(root_options).tap{|r| r.root = r }
    end

    def doc_of_type(type, opts={})
      doc = PMP::CollectionDocument.new(options.merge(root:root(opts)).merge(opts))
      doc.links['profile'] = Link.new(href: profile_href_for_type(type), type: "application/vnd.collection.doc+json")
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
