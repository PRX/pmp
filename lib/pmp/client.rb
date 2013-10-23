# -*- encoding: utf-8 -*-

module PMP
  class Client

    include Configuration

    def initialize(options={}, &block)
      apply_configuration(options)
      yield(self) if block_given?
    end

    def token(opts={})
      @token ||= PMP::Token.new(options.merge(opts)).get_token
    end

    def root(opts={}, &block)
      opts = options.merge(href: endpoint).merge(opts)
      @root ||= PMP::CollectionDocument.new(opts, &block)
    end

    # def new_of_type(type)
    #   doc = PMP::CollectionDocument.new(options)
    #   profile = Link.new
    #   profile.href = 
    #   doc.links['profile'] = Link.new

    # end

  end
end
