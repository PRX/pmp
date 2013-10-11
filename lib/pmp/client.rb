# -*- encoding: utf-8 -*-

module PMP
  class Client

    def token(opts={})
      PMP::Token.new(opts).get_token
    end

    def root(opts={}, &block)      
      PMP::CollectionDocument.new(opts, &block)
    end

  end
end
