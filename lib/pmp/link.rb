# -*- encoding: utf-8 -*-

require 'uri_template'
require 'ostruct'

module PMP
  class Link < OpenStruct

    include Parser

    attr_accessor :parent

    attr_accessor :params

    # # it's a struct, we don't have to set these, up, but have a list of what we define particular logic for
    # :href,          # "https://api-sandbox.pmp.io/docs/af676335-21df-4486-ab43-e88c1b48f026"
    # :href_template, # "https://api-sandbox.pmp.io/users{?limit,offset,tag,collection,text,searchsort,has}"
    # :href_vars,     # { "collection": "https://github.com/publicmediaplatform/pmpdocs/wiki/Content-Retrieval" }
    # :hreflang,      # Language of the linked document
    # :hints,         # Hints about interacting with the link, such as HTTP methods, e.g. "hints": { "allow": ["GET", "PUT", "DELETE"] }
    # :rels,          # [ "urn:pmp:query:users" ]
    # :method,        # http method - get, post, put, etc.
    # :type,          # 'image/png' - mime type of linked resource
    # :title,         # name/title of thing linked in
    # :operation,     # used by permissions link - read, write
    # :blacklist,     # used by permissions link

    def initialize(parent, link)
      super()
      self.parent = parent || PMP::CollectionDocument.new
      self.params = link.delete('params') || {}
      parse_attributes(link)
    end

    def attributes
      marshal_dump
    end

    def as_json
      extract_attributes
    end

    def url
      URITemplate.new(href_template || href).expand(_params)
    end

    def retrieve
      @_retrieved ||= parent.request((method || 'get').to_sym, url)
    end

    def method_missing(method, *args)
      begin
        super
      rescue NoMethodError => err
        self.retrieve.send(method, *args)
      end
    end

  end
end
