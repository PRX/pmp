# -*- encoding: utf-8 -*-

require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

require 'pmp/link'

require 'webmock/minitest'

describe PMP::Link do

  before(:each) {
    @parent = Minitest::Mock.new
    @info = {'href' => 'http://api-sandbox.pmp.io/docs/'}
    @link = PMP::Link.new(@parent, @info)
  }

  it "can create a new link" do
    @link.wont_be_nil
  end

  it "has a parent" do
    @link = PMP::Link.new
    @link.parent.wont_be_nil

    @link = PMP::Link.new({}, @info)
    @link.parent.must_equal({})
  end

  it "can save params to attributes" do
    @link.href.must_equal 'http://api-sandbox.pmp.io/docs/'
  end

  it "can retrieve link resource" do
    @link.href.must_equal 'http://api-sandbox.pmp.io/docs/'
  end

  it "can become json" do
    @link.as_json.must_equal @info
  end

  it "gets a url based on an href string" do
    @link.href.must_equal 'http://api-sandbox.pmp.io/docs/'
    @link.href_template.must_be_nil
    @link.params.must_equal({})

    url = @link.url
    url.must_equal 'http://api-sandbox.pmp.io/docs/'
  end

  it "can get a link for templated href" do
    l = {
            "hints" => {
                "allow" => [
                    "GET"
                ]
            },
            "href-template" => "https://api-sandbox.pmp.io/docs{?limit,offset,tag,collection,text,searchsort,has,author,distributor,distributorgroup,startdate,enddate,profile,language}",
            "href-vars" => {
                "author" => "https://github.com/publicmediaplatform/pmpdocs/wiki/Content-Retrieval",
                "collection" => "https://github.com/publicmediaplatform/pmpdocs/wiki/Content-Retrieval",
                "distributor" => "https://github.com/publicmediaplatform/pmpdocs/wiki/Content-Retrieval",
                "distributorgroup" => "https://github.com/publicmediaplatform/pmpdocs/wiki/Content-Retrieval",
                "enddate" => "https://github.com/publicmediaplatform/pmpdocs/wiki/Content-Retrieval",
                "has" => "https://github.com/publicmediaplatform/pmpdocs/wiki/Content-Retrieval",
                "language" => "https://github.com/publicmediaplatform/pmpdocs/wiki/Content-Retrieval",
                "limit" => "https://github.com/publicmediaplatform/pmpdocs/wiki/Content-Retrieval",
                "offset" => "https://github.com/publicmediaplatform/pmpdocs/wiki/Content-Retrieval",
                "profile" => "https://github.com/publicmediaplatform/pmpdocs/wiki/Content-Retrieval",
                "searchsort" => "https://github.com/publicmediaplatform/pmpdocs/wiki/Content-Retrieval",
                "startdate" => "https://github.com/publicmediaplatform/pmpdocs/wiki/Content-Retrieval",
                "tag" => "https://github.com/publicmediaplatform/pmpdocs/wiki/Content-Retrieval",
                "text" => "https://github.com/publicmediaplatform/pmpdocs/wiki/Content-Retrieval"
            },
            "rels" => [
                "urn:pmp:query:docs"
            ],
            "title" => "Query for documents"
        }

    @link = PMP::Link.new(@parent, l)
    @link.hints.must_equal l['hints']
    @link.url.must_equal "https://api-sandbox.pmp.io/docs"
    @link.where('limit' => 10).url.must_equal "https://api-sandbox.pmp.io/docs?limit=10"
    @link.url.must_equal "https://api-sandbox.pmp.io/docs"
  end

end
