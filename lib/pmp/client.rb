# -*- encoding: utf-8 -*-

module PMP
  class Client

    include Configuration

    def initialize(options={}, &block)
      apply_configuration(options)
      yield(self) if block_given?
    end

    def token(opts={})
      PMP::Token.new(options.merge(opts)).get_token
    end

    def root(opts={}, &block)      
      PMP::CollectionDocument.new(options.merge(opts), &block)
    end

  end
end
