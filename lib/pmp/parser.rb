# -*- encoding: utf-8 -*-

module PMP
  module Parser

    include Utils

    def as_json(options={})
      result = {}
      result['version']    = self.version
      result['attributes'] = extract_attributes
      result['links']      = extract_links
      result
    end

    def extract_attributes(obj=self)
      obj.attributes.inject({}) do |result, pair|
        value = pair.last
        if !value.is_a?(PMP::Link)
          name = to_json_key_name(pair.first)
          result[name] = value
        end
        result
      end
    end

    def extract_links(obj=self)
      obj.attributes.inject({}) do |result, pair|
        value = pair.last
        if value.is_a?(PMP::Link)
          name = to_json_key_name(pair.first)
          result[name] = extract_attributes(value)
        end
        result
      end
    end

    def parse(doc)
      return if (!doc)
      parse_version(doc['version'])
      parse_attributes(doc['attributes'])
      parse_links(doc['links'])
      parse_items(doc['items'])
      # parse_error(doc)
    end

    def parse_version(document)
      self.version = document || '1.0'
    end

    def parse_attributes(document)
      Array(document).each do |k,v|
        self.send("#{to_ruby_safe_name(k)}=", v)
      end
    end

    def parse_links(document)
      Array(document).each do |k,v|

        link = if !v.is_a?(Array)
          Link.new(self, v)
        elsif v.size == 1
          Link.new(self, v.first)
        elsif v.size > 0
          v.map{|l| Link.new(self, l)}
        end
        self.send("#{to_ruby_safe_name(k)}=", link) if link
      end
    end

    def parse_items(document)
      self.items = Array(document).collect{|i| PMP::CollectionDocument.new(document:i)}
    end

  end
end
