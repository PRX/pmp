# class to handle/manage and keep track of list of links in this doc

module PMP
  class Links < Hash

    include Utils

    attr_accessor :_parent

    def initialize(parent)
      super()
      self._parent = parent
    end

    def []=(k, link)
      super
      _parent.send("#{to_ruby_safe_name(k)}=", link)
    end

  end
end
