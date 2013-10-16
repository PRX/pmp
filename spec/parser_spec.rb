# -*- encoding: utf-8 -*-

require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

require 'ostruct'

require 'pmp/parser'

class TestParser < OpenStruct
  include PMP::Parser

  attr_accessor :version

  def links
    @links ||= PMP::Links.new(self)
  end

  def attributes
    marshal_dump.delete_if{|k,v| links.keys.include?(k)}
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
    # puts "basic as_json: #{hash}"
    hash.keys.sort.must_equal ['attributes', 'links', 'version']
    hash['attributes']['guid'].must_equal "f84e9018-5c21-4b32-93f8-d519308620f0"
    hash['links'].keys.sort.must_equal ["collection", "profile", "self"]
  end

  it "parses query links into a hash based on rels" do
    tc = TestParser.new
    tc.parse(json_fixture(:collection_root))
    tc.query.must_be_instance_of Hash
    tc.query.keys.sort.must_equal ["urn:pmp:hreftpl:docs", "urn:pmp:hreftpl:profiles", "urn:pmp:hreftpl:schemas", "urn:pmp:query:docs", "urn:pmp:query:files", "urn:pmp:query:groups", "urn:pmp:query:guids", "urn:pmp:query:users"]
  end


end
