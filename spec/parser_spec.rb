# -*- encoding: utf-8 -*-

require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

require 'ostruct'

require 'pmp/parser'

class TestParser < OpenStruct
  include PMP::Parser

  def attributes
    self.marshal_dump
  end

end

describe PMP::Parser do

  it "will not parse nil document" do
    tc = TestParser.new
    tc.parse(nil)
  end

  it "will un-parse to hash for json serialization" do
    tc = TestParser.new
    tc.parse(json_fixture(:collection_basic))
    hash = tc.as_json
    hash.keys.sort.must_equal ['attributes', 'links', 'version']
    hash['attributes']['guid'].must_equal "f84e9018-5c21-4b32-93f8-d519308620f0"
    hash['links'].keys.sort.must_equal ["collection", "profile", "self"]
  end

end
