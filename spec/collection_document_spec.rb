# -*- encoding: utf-8 -*-

require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

require 'pmp/collection_document'
require 'webmock/minitest'

describe PMP::CollectionDocument do

  describe 'make' do

    before(:each) {
      @doc = PMP::CollectionDocument.new
    }

    it "can create a new, blank collection doc" do
      @doc.wont_be_nil
      @doc.must_be_instance_of PMP::CollectionDocument
    end

    it "can get options from configuration" do
      @doc.options.wont_be_nil
      @doc.options[:adapter].must_equal :excon
    end

    it "should default href to endpoint" do
      @doc.href.must_equal "https://api.pmp.io/"
    end

  end

  describe 'make from response' do

    it "can create from document" do
      response = mashify({
        version: '1.0'
      })

      doc = PMP::CollectionDocument.new(document: response)
      doc.version.must_equal '1.0'
    end

    it "can create from remote result" do
      raw = Minitest::Mock.new
      raw.expect(:status, 200)
      raw.expect(:body, mashify({ version: '1.0' }))
      response = PMP::Response.new(raw, {})

      doc = PMP::CollectionDocument.new(response: response)
      doc.version.must_equal '1.0'
      doc.must_be :loaded
    end

  end

  describe "parse from doc" do

    before(:each) {
      @doc = PMP::CollectionDocument.new(document: json_fixture(:collection_basic))
    }

    it "should assign attributes" do
      @doc.guid.must_equal "f84e9018-5c21-4b32-93f8-d519308620f0"
      @doc.valid.from.must_equal "2013-05-10T15:17:00.598Z"
    end

    it "should set-up links" do
      @doc.profile.must_be_instance_of PMP::Link
      @doc.profile.href.must_equal "http://api-sandbox.pmp.io/profiles/story"
      @doc.self.href.must_equal "http://api-sandbox.pmp.io/docs/f84e9018-5c21-4b32-93f8-d519308620f0"
      @doc.collection.href.must_equal "http://api-sandbox.pmp.io/docs/"
    end

    it "should serialize to collection.doc+json" do
      @doc = PMP::CollectionDocument.new(document: json_fixture(:collection_basic))
      @doc.to_json.must_equal '{"version":"1.0","links":{"profile":[{"href":"http://api-sandbox.pmp.io/profiles/story"}],"self":[{"href":"http://api-sandbox.pmp.io/docs/f84e9018-5c21-4b32-93f8-d519308620f0"}],"collection":[{"href":"http://api-sandbox.pmp.io/docs/"}]},"attributes":{"guid":"f84e9018-5c21-4b32-93f8-d519308620f0","title":"Peers Find Less Pressure Borrowing From Each Other","published":"2013-05-10T15:17:00.598Z","valid":{"from":"2013-05-10T15:17:00.598Z","to":"2213-05-10T15:17:00.598Z"},"byline":"by SOME PERSON","hreflang":"en","description":"","contentencoded":"...","contenttemplated":"..."}}'
    end

  end

  describe "loading" do

    before(:each) {
      root_doc =  json_file(:collection_root)

      stub_request(:get, "https://api.pmp.io/").
        with(:headers => {'Accept'=>'application/vnd.pmp.collection.doc+json', 'Authorization'=>'Bearer thisisatesttoken', 'Content-Type'=>'application/vnd.pmp.collection.doc+json', 'Host'=>'api.pmp.io:443', 'User-Agent'=>'PMP Ruby Gem 0.0.1'}).
        to_return(:status => 200, :body => root_doc, :headers => {})

      @doc = PMP::CollectionDocument.new(oauth_token: 'thisisatesttoken')
    }

    it "should use oauth token" do
      @doc.oauth_token.must_equal 'thisisatesttoken'
    end

    it "should load" do
      @doc.wont_be :loaded
      @doc.load
      @doc.must_be :loaded
    end

    it "should not load lazily for assignment" do
      @doc.foo = 'bar'
      @doc.wont_be :loaded
    end

    it "should load lazily when attr not found" do
      @doc.wont_be :loaded
      creator = @doc.creator
      @doc.must_be :loaded
      creator.must_be_instance_of PMP::Link
    end

  end

  describe "queries" do

    before(:each) {
      root_doc =  json_file(:collection_root)

      stub_request(:get, "https://api.pmp.io/").
        with(:headers => {'Accept'=>'application/vnd.pmp.collection.doc+json', 'Authorization'=>'Bearer thisisatesttoken', 'Content-Type'=>'application/vnd.pmp.collection.doc+json', 'Host'=>'api.pmp.io:443', 'User-Agent'=>'PMP Ruby Gem 0.0.1'}).
        to_return(:status => 200, :body => root_doc, :headers => {})

      @doc = PMP::CollectionDocument.new(oauth_token: 'thisisatesttoken')
    }

    it "should get the list of query links" do
      queries = @doc.query
      queries.must_be_instance_of Hash
    end

    it "should get a query by rels" do
      queries = @doc.query
      queries["urn:pmp:query:docs"].must_be_instance_of PMP::Link
    end

  end

end
