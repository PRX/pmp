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
      parent.send("#{to_ruby_safe_name(k)}=", link)
    end

  end
end
