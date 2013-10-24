# -*- encoding: utf-8 -*-

require 'simplecov'
require 'coveralls'

SimpleCov.command_name 'Unit Tests'
SimpleCov.formatter = SimpleCov::Formatter::HTMLFormatter
# SimpleCov.formatter = Coveralls::SimpleCov::Formatter
SimpleCov.start

require 'minitest'
require 'minitest/autorun'
require 'minitest/spec'
require 'minitest/mock'
require 'webmock/minitest'
require 'hashie/mash'

require 'pmp'

# helper method to create mashified test docs, that look like what comes out of the faraday middleware
def mashify(body)
  case body
  when Hash
    ::Hashie::Mash.new(body)
  when Array
    body.map { |item| parse(item) }
  else
    body
  end
end

def json_fixture(name)
  mashify(JSON.parse(json_file(name)))
end

def json_file(name)
  File.read( File.dirname(__FILE__) + "/fixtures/#{name}.json")
end
