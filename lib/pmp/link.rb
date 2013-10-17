# -*- encoding: utf-8 -*-

require 'uri_template'
require 'ostruct'

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

module PMP
  class Link < OpenStruct

    include Parser

    attr_accessor :parent

    attr_accessor :params

    def initialize(parent=PMP::CollectionDocument.new, link={})
      super()
      self.parent = parent
      self.params = link.delete('params') || {}
      # puts "params: #{params.inspect}"
      parse_attributes(link)
    end

    def href
      self[:href]
    end

    def href_template
      self[:href_template]
    end

    def method
      self[:method]
    end

    def attributes
      HashWithIndifferentAccess.new(marshal_dump)
    end

    def where(params={})
      self.class.new(parent, attributes.merge({'params'=>params}))
    end

    def as_json
      extract_attributes
    end

    def url
      # puts "url href_template: #{href_template}"
      # puts "url href: #{href}"
      URITemplate.new(href_template || href).expand(params)
    end

    def retrieve
      # puts "retrieve method: #{method}"
      # puts "retrieve url: #{url}"
      parent.request((method || 'get').to_sym, url)
    end

    def method_missing(method, *args)
      # puts "mm: #{method}"
      # this is a method the link supports, call the link
      # if this is an assignment, assign to the link
      # if you want to assign to a linked doc(s), need to retrieve first
      if self.respond_to?(method)
        self.send(method, *args)
      elsif method.to_s.last == '='
       super
      else
        # puts "mm retrieve and send: #{method}"
        self.retrieve.send(method, *args)
      end
    end

  end
end
