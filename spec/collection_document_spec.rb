# -*- encoding: utf-8 -*-

require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

require 'pmp/collection_document'

require 'webmock/minitest'

describe PMP::CollectionDocument do

  it "can create a new, blank collection doc" do
    doc = PMP::CollectionDocument.new
  end

  it "can get options from configuration" do
    doc = PMP::CollectionDocument.new
    doc.options.wont_be_nil
    doc.options[:adapter].must_equal :excon
  end

  it "should default href to endpoint" do
    doc = PMP::CollectionDocument.new
    doc.href.must_equal "https://api.pmp.io/"
  end

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

  it "should assign attributes" do
    doc = PMP::CollectionDocument.new(document: json_fixture(:collection_basic))
    doc.guid.must_equal "f84e9018-5c21-4b32-93f8-d519308620f0"
    doc.valid.from.must_equal "2013-05-10T15:17:00.598Z"
  end

  it "should set-up links" do
    doc = PMP::CollectionDocument.new(document: json_fixture(:collection_basic))
    doc.profile.must_be_instance_of PMP::Link
    doc.profile.href.must_equal "http://api-sandbox.pmp.io/profiles/story"
    doc.self.href.must_equal "http://api-sandbox.pmp.io/docs/f84e9018-5c21-4b32-93f8-d519308620f0"
    doc.collection.href.must_equal "http://api-sandbox.pmp.io/docs/"
  end

  it "should load" do
    stub_request(:get, "https://api.pmp.io/").
      with(:headers => {'Accept'=>'application/vnd.pmp.collection.doc+json', 'Authorization'=>'Bearer thisisatesttoken', 'Content-Type'=>'application/vnd.pmp.collection.doc+json', 'Host'=>'api.pmp.io:443', 'User-Agent'=>'PMP Ruby Gem 0.0.1'}).
      to_return(:status => 200, :body => "", :headers => {})

    doc = PMP::CollectionDocument.new(oauth_token: 'thisisatesttoken')
    doc.oauth_token.must_equal 'thisisatesttoken'
    doc.wont_be :loaded
    doc.load
    doc.must_be :loaded
  end

  it "should serialize to collection.doc+json" do
    doc = PMP::CollectionDocument.new(document: json_fixture(:collection_basic))
    doc.to_json.must_equal '{"version":"1.0","attributes":{"guid":"f84e9018-5c21-4b32-93f8-d519308620f0","title":"Peers Find Less Pressure Borrowing From Each Other","published":"2013-05-10T15:17:00.598Z","valid":{"from":"2013-05-10T15:17:00.598Z","to":"2213-05-10T15:17:00.598Z"},"byline":"by SOME PERSON","hreflang":"en","description":"","contentencoded":"...","contenttemplated":"...","items":[]},"links":{"profile":{"href":"http://api-sandbox.pmp.io/profiles/story"},"self":{"href":"http://api-sandbox.pmp.io/docs/f84e9018-5c21-4b32-93f8-d519308620f0"},"collection":{"href":"http://api-sandbox.pmp.io/docs/"}}}'
  end

end
