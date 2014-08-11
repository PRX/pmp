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
      @doc.href.must_be_nil
      @doc.href = "https://api.pmp.io/"
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
      @doc.profile.first.must_be_instance_of PMP::Link
      @doc.profile.first.href.must_equal "http://api-sandbox.pmp.io/profiles/story"
      @doc.self.first.href.must_equal "http://api-sandbox.pmp.io/docs/f84e9018-5c21-4b32-93f8-d519308620f0"
      @doc.collection.first.href.must_equal "http://api-sandbox.pmp.io/docs/"
    end

    it "should serialize to collection.doc+json" do
      @doc = PMP::CollectionDocument.new(document: json_fixture(:collection_basic))
      @doc.to_json.must_equal '{"version":"1.0","links":{"profile":[{"href":"http://api-sandbox.pmp.io/profiles/story"}],"self":[{"href":"http://api-sandbox.pmp.io/docs/f84e9018-5c21-4b32-93f8-d519308620f0"}],"collection":[{"href":"http://api-sandbox.pmp.io/docs/"}],"queries":[],"edit-form":[]},"attributes":{"guid":"f84e9018-5c21-4b32-93f8-d519308620f0","title":"Peers Find Less Pressure Borrowing From Each Other","published":"2013-05-10T15:17:00.598Z","valid":{"from":"2013-05-10T15:17:00.598Z","to":"2213-05-10T15:17:00.598Z"},"byline":"by SOME PERSON","hreflang":"en","description":"","contentencoded":"...","contenttemplated":"..."}}'
    end

    it "provides list of attributes (not links)" do
      @doc.attributes_map.keys.must_be :include?, 'title'
      @doc.attributes_map.keys.wont_be :include?, 'self'
    end

  end

  describe "loading" do

    before(:each) {
      root_doc =  json_file(:collection_root)

      stub_request(:get, "https://api.pmp.io/").
        with(:headers => {'Accept'=>'application/vnd.collection.doc+json', 'Authorization'=>'Bearer thisisatesttoken', 'Content-Type'=>'application/vnd.collection.doc+json', 'Host'=>'api.pmp.io:443'}).
        to_return(:status => 200, :body => root_doc, :headers => {})

      @doc = PMP::CollectionDocument.new(oauth_token: 'thisisatesttoken', href: "https://api.pmp.io/", client_id: "fake", client_secret: "fake")
    }

    it "should use oauth token" do
      @doc.oauth_token.must_equal 'thisisatesttoken'
    end

    it "should should get oauth_token if missing" do

      response_body = {
        access_token: 'thisisalsoatesttoken',
        token_type: "Bearer",
        token_issue_date: DateTime.now,
        token_expires_in: 24*60*60
      }.to_json

      stub_request(:post, "https://api.pmp.io/auth/access_token").
        with(:body => {"grant_type"=>"client_credentials"},
             :headers => {'Accept'=>'application/json', 'Authorization'=>'Basic ZmFrZTpmYWtl', 'Content-Type'=>'application/x-www-form-urlencoded', 'Host'=>'api.pmp.io:443'}).
        to_return(:status => 200, :body => response_body, :headers => {'Content-Type' => 'application/json; charset=utf-8'})

      @doc.oauth_token = nil
      @doc.setup_oauth_token
      @doc.oauth_token.must_equal 'thisisalsoatesttoken'
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
      creator = @doc.creator.first
      @doc.must_be :loaded
      creator.must_be_instance_of PMP::Link
    end

    it "should provide a list of links" do
      @doc.load
      @doc.links.keys.sort.must_equal ["auth", "bookmark", "creator", "edit", "item", "navigation", "query"]
      @doc.links['creator'].first.must_be_instance_of PMP::Link
    end

  end

  describe "queries" do

    before(:each) {
      root_doc =  json_file(:collection_root)

      stub_request(:get, "https://api.pmp.io/").
        with(:headers => {'Accept'=>'application/vnd.collection.doc+json', 'Authorization'=>'Bearer thisisatesttoken', 'Content-Type'=>'application/vnd.collection.doc+json', 'Host'=>'api.pmp.io:443'}).
        to_return(:status => 200, :body => root_doc, :headers => {})

      @doc = PMP::CollectionDocument.new(oauth_token: 'thisisatesttoken', href: "https://api.pmp.io/")
    }

    it "should get the list of query links" do
      queries = @doc.query
      queries.must_be_instance_of HashWithIndifferentAccess
    end

    it "should get a query by rels" do
      queries = @doc.query
      queries["urn:collectiondoc:query:docs"].must_be_instance_of PMP::Link
    end

    it "should handle 404 results on a search" do

      stub_request(:get, "https://api-sandbox.pmp.io/docs").
        with(:headers => {'Accept'=>'application/vnd.collection.doc+json', 'Authorization'=>'Bearer thisisatesttoken', 'Content-Type'=>'application/vnd.collection.doc+json', 'Host'=>'api-sandbox.pmp.io:443'}).
        to_return(:status=>404, :body=>"Not Found", :remote_ip=>"107.20.158.113", :headers=>{"Access-Control-Allow-Headers"=>"origin, x-http-method-override, accept, content-type, authorization, x-pingother", "Access-Control-Allow-Methods"=>"GET,OPTIONS,HEAD,PUT,POST,DELETE,PATCH", "Access-Control-Allow-Origin"=>"*", "Content-Type"=>"application/vnd.collection.doc+json", "Date"=>"Thu, 24 Oct 2013 17:20:04 GMT", "Vary"=>"Accept-Encoding", "X-Powered-By"=>"Express", "X-Response-Time"=>"18ms", "Content-Length"=>"9", "Connection"=>"keep-alive"})

      @doc.query["urn:collectiondoc:query:docs"].items.must_equal []
    end

  end

  describe 'persistence' do

    it "can set missing guid" do
      doc = PMP::CollectionDocument.new
      doc.guid.must_be_nil
      doc.set_guid_if_blank
      doc.guid.wont_be_nil
    end

    it "can add a new link" do
      doc = PMP::CollectionDocument.new
      link = PMP::Link.new(href: 'http://pmp.io/test')
      doc.links['test'] = link
      doc.test.must_equal link
    end

    it "can save a record" do

      # stub getting the root doc
      root_doc =  json_file(:collection_root)
      stub_request(:get, "https://api.pmp.io/").
        with(:headers => {'Accept'=>'application/vnd.collection.doc+json', 'Content-Type'=>'application/vnd.collection.doc+json', 'Host'=>'api.pmp.io:443'}).
        to_return(:status => 200, :body => root_doc, :headers => {})

      # stub saving the new doc
      stub_request(:put, "https://publish-sandbox.pmp.io/docs/c144e4df-021b-41e6-9cf3-42ac49bcbd42").
        with(:headers => {'Accept'=>'application/vnd.collection.doc+json', 'Content-Type'=>'application/vnd.collection.doc+json', 'Host'=>'publish-sandbox.pmp.io:443'}).
        to_return(:status => 404, :body => '{"error":"FAIL"}')

      doc = PMP::CollectionDocument.new(oauth_token: 'thisisatestvalueonly')
      doc.guid = "c144e4df-021b-41e6-9cf3-42ac49bcbd42"
      doc.title = "testing"
      proc{ doc.save }.must_raise Faraday::Error::ResourceNotFound
    end

    it "should handle 404 results on a save" do

      # stub getting the root doc
      root_doc =  json_file(:collection_root)

      stub_request(:get, "https://api.pmp.io/").
        with(:headers => {'Accept'=>'application/vnd.collection.doc+json', 'Content-Type'=>'application/vnd.collection.doc+json', 'Host'=>'api.pmp.io:443'}).
        to_return(:status => 200, :body => root_doc, :headers => {})

      doc = PMP::CollectionDocument.new(oauth_token: 'thisisatestvalueonly')


      stub_request(:put, "https://publish-sandbox.pmp.io/docs/c144e4df-021b-41e6-9cf3-42ac49bcbd42").
        with(:body => "{\"links\":{},\"attributes\":{\"guid\":\"c144e4df-021b-41e6-9cf3-42ac49bcbd42\",\"title\":\"testing\"}}",
             :headers => {'Accept'=>'application/vnd.collection.doc+json', 'Authorization'=>'Bearer thisisatestvalueonly', 'Content-Type'=>'application/vnd.collection.doc+json', 'Host'=>'publish-sandbox.pmp.io:443'}).
        to_return(:status => 200, :body => '{"url":"https://api-sandbox.pmp.io/docs/c144e4df-021b-41e6-9cf3-42ac49bcbd42"}')

      doc.guid = "c144e4df-021b-41e6-9cf3-42ac49bcbd42"
      doc.title = "testing"
      doc.wont_be :loaded
      doc.save
      
      doc.must_be :loaded
      doc.href.must_equal "https://api-sandbox.pmp.io/docs/c144e4df-021b-41e6-9cf3-42ac49bcbd42"


      stub_request(:put, "https://publish-sandbox.pmp.io/docs/c144e4df-021b-41e6-9cf3-42ac49bcbd42").
        with(:body => "{\"links\":{},\"attributes\":{\"guid\":\"c144e4df-021b-41e6-9cf3-42ac49bcbd42\",\"title\":\"testing an update\"}}",
             :headers => {'Accept'=>'application/vnd.collection.doc+json', 'Authorization'=>'Bearer thisisatestvalueonly', 'Content-Type'=>'application/vnd.collection.doc+json', 'Host'=>'publish-sandbox.pmp.io:443'}).
        to_return(:status => 200, :body => '{"url":"https://api-sandbox.pmp.io/docs/c144e4df-021b-41e6-9cf3-42ac49bcbd42"}')

      doc.title.must_equal "testing"
      doc.title = "testing an update"
      doc.save
      doc.title.must_equal "testing an update"
    end

    it "can delete a record" do

      # stub getting the root doc
      root_doc =  json_file(:collection_root)
      stub_request(:get, "https://api.pmp.io/").
        with(:headers => {'Accept'=>'application/vnd.collection.doc+json', 'Content-Type'=>'application/vnd.collection.doc+json', 'Host'=>'api.pmp.io:443'}).
        to_return(:status => 200, :body => root_doc, :headers => {})

      stub_request(:delete, "https://publish-sandbox.pmp.io/docs/c144e4df-021b-41e6-9cf3-42ac49bcbd42").
        with(:headers => {'Accept'=>'application/vnd.collection.doc+json', 'Content-Type'=>'application/vnd.collection.doc+json', 'Host'=>'publish-sandbox.pmp.io:443'}).
        to_return(:status => 204, :body => "", :headers => {})

      doc = PMP::CollectionDocument.new(oauth_token: 'thisisatestvalueonly')
      doc.guid = "c144e4df-021b-41e6-9cf3-42ac49bcbd42"
      doc.delete
    end

  end

end
