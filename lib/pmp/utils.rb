# -*- encoding: utf-8 -*-

module PMP
  module Utils

    def to_ruby_safe_name(name)
      safe = name.strip
      safe = safe.gsub(/[^\w_!?=]+/, '_').sub(/^[0-9!?=]/, '')
      safe[0..-2].gsub(/[!?=]+/, '_') + safe[-1]
    end

    def to_json_key_name(name)
      name.to_s.gsub(/_/, '-')
    end

  end
end