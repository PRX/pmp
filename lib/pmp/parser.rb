# -*- encoding: utf-8 -*-

module PMP
  module Parser

    def parse(doc)
      return if (!doc)
      parse_version(doc)
      parse_attributes(doc)
      parse_links(doc)
      parse_items(doc)
      # parse_error(doc)
    end

    def parse_version(document)
      self.version = document['version'] || '1.0'
    end

    def parse_attributes(document)
      Array(document['attributes']).each do |k,v|
        self.send("#{safe_name(k)}=", v)
      end
    end

    def parse_links(document)
      Array(document['links']).each do |k,v|

        link = if !v.is_a?(Array)
          Link.new(self, v)
        elsif v.size == 1
          Link.new(self, v.first)
        else
          v.map{|l| Link.new(self, l)}
        end
        self.send("#{safe_name(k)}=", link)
      end
    end

    def parse_items(document)
      self.items = Array(document['items']).collect{|i| PMP::CollectionDocument.new(document:i)}
    end

  end
end
