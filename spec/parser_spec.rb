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

  it "will parse links without array comtainer" do
    tc = TestParser.new
    tc.parse(json_fixture(:collection_links))
    tc.links['self'].href.must_equal "http://api-sandbox.pmp.io/docs/f84e9018-5c21-4b32-93f8-d519308620f0"
  end

  it "will parse empty arrays into empty arrays" do
    tc = TestParser.new
    tc.parse(json_fixture(:collection_links))
    tc.links['edit-form'].must_equal Array.new
  end

  it "will un-parse to hash for json serialization" do
    tc = TestParser.new
    tc.parse(json_fixture(:collection_basic))
    hash = tc.as_json
    # puts "basic as_json: #{hash}"
    hash.keys.sort.must_equal ['attributes', 'links', 'version']
    hash['attributes']['guid'].must_equal "f84e9018-5c21-4b32-93f8-d519308620f0"
    hash['links'].keys.sort.must_equal ["collection", "edit-form", "profile", "queries", "self"]
  end

  it "parses query links into a hash based on rels" do
    tc = TestParser.new
    tc.parse(json_fixture(:collection_root))
    tc.query.must_be_instance_of HashWithIndifferentAccess
    tc.query.keys.sort.must_equal ["urn:pmp:hreftpl:docs", "urn:pmp:hreftpl:profiles", "urn:pmp:hreftpl:schemas", "urn:pmp:query:docs", "urn:pmp:query:groups", "urn:pmp:query:guids", "urn:pmp:query:users"]
  end

  it "will unparse links" do
    tc = TestParser.new
    tc.parse(json_fixture(:collection_root))
    tc.links['test1'] = PMP::Link.new(href: 'https://api-sandbox.pmp.io/test1')
    tc.links['test2'] = [PMP::Link.new(href: 'https://api-sandbox.pmp.io/test2a'), PMP::Link.new(href: 'https://api-sandbox.pmp.io/test2b')]
    hash = tc.as_json
    hash['links'].keys.sort.must_equal ["creator", "edit", "navigation", "query", "test1", "test2"]
  end

end
