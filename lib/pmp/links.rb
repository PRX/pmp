# class to handle/manage and keep track of list of links in this doc

module PMP
  class Links < HashWithIndifferentAccess

    include Utils

    attr_accessor :parent

    def initialize(parent)
      super()
      self.parent = parent
    end

    def []=(k, link)
      super
      set_parent(link)
      add_link_name(k)
    end

    def add_link_name(name)
      name = name.to_sym
      unless parent.respond_to?(name)
        parent.define_singleton_method(name) { self.links[name] }
        parent.define_singleton_method("#{name}=") { |x| self.links[name] = x }
      end
    end

    def set_parent(link)
      if link.respond_to?(:parent)
        link.parent = self.parent
      elsif link.is_a?(Hash)
        link.values.each{|l| set_parent(l)}
      elsif link.is_a?(Enumerable)
        link.each{|l| set_parent(l)}
      end
    end

  end
end
