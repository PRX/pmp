# -*- encoding: utf-8 -*-

module PMP

  class Response
    attr_accessor :raw, :request

    def initialize(raw, request)
      @raw     = raw
      @request = request

      check_for_error(raw)
    end

    def check_for_error(response)
      status_code_type = response.status.to_s[0]
      case status_code_type
      when "2"
        # puts "all is well, status: #{response.status}"
      when "4", "5"
        raise "Whoops, error back from PMP: #{response.status}"
      else
        raise "Unrecongized status code: #{response.status}"
      end
    end

    def body
      self.raw.body
    end

  end
end
