# -*- encoding: utf-8 -*-

module PMP
  module Parser

    include Utils

    def as_json(options={})
      result = {}
      result['version']    = self.version
      result['links']      = extract_links
      result['attributes'] = extract_attributes

      result
    end

    def extract_attributes(obj=self)
      obj.attributes.inject({}) do |result, pair|
        value = pair.last
        name = to_json_key_name(pair.first)
        result[name] = value
        result
      end
    end

    def extract_links(obj=self)
      obj.links.inject({}) do |result, pair|
        value = pair.last
        name = to_json_key_name(pair.first)

        links = if value.is_a?(PMP::Link)
          [extract_attributes(value)]
        elsif value.is_a?(Array)
          value.map{|v| extract_attributes(v)}
        elsif value.is_a?(Hash)
          value.values.map{|v| extract_attributes(v)}
        end

        result[name] = links

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
        link = parse_link(k,v)
        if link
          self.links[k] = link
        end
      end
    end

    def parse_link(name, info)
      if ['query', 'edit', 'navigation'].include?(name.to_s)
        parse_links_list(info)
      elsif !info.is_a?(Array)
        Link.new(info)
      elsif info.size == 1
        Link.new(info.first)
      elsif info.size > 0        
        info.map{|l| Link.new(l)}
      end
    end

    def parse_links_list(links)
      links.inject({}) do |results, query|
        rel = query['rels'].first
        results[rel] = Link.new(query)
        results
      end
    end

    def parse_items(document)
      self.items = Array(document).collect{|i| PMP::CollectionDocument.new(document:i)}
    end

  end
end
