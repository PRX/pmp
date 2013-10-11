require 'uri_template'

module PMP

  # this is a placeholder so we can lazy load resources
  class Link

    # it's a struct, we don't have to set these, up, but have a list of what we define particular logic for
    attr_accessor :href,          # "https://api-sandbox.pmp.io/docs/af676335-21df-4486-ab43-e88c1b48f026"
                  :href_template, # "https://api-sandbox.pmp.io/users{?limit,offset,tag,collection,text,searchsort,has}"
                  :href_vars,     # { "collection": "https://github.com/publicmediaplatform/pmpdocs/wiki/Content-Retrieval" }
                  :rels,          # [ "urn:pmp:query:users" ]
                  :hints,
                  :method,
                  :_parent

    def initialize(parent, link)
      self._parent       = parent || PMP::CollectionDocument.new

      self.href          = link['href']
      self.href_template = link['href-template']
      self.href_vars     = link['href-vars']
      self.method        = (link['method'] || :get).to_sym
      self.rels          = link['rels']
      self.hints         = link['hints']
    end

    def retrieve
      if !href_template && href
        parent.request(method, href)
      end
    end

    def method_missing(method, *args)
      self.retrieve.send(method, *args)
    end

  end
end
