# -*- encoding: utf-8 -*-

require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe PMP::Client do

  before(:each) {
    @pmp = PMP::Client.new(oauth_token: 'thisisatestvalueonly')
  }

  it "make with options and pass along" do
    pmp = PMP::Client.new(oauth_token: 'thisisatestvalueonly')
    pmp.oauth_token.must_equal 'thisisatestvalueonly'
    pmp.root.oauth_token.must_equal 'thisisatestvalueonly'
  end

  it "returns a root api object" do
    @pmp.root.wont_be_nil
    @pmp.root.wont_be :loaded?
    @pmp.root.href.must_equal "https://api.pmp.io/"
  end

  it "root doc can be loaded" do

    root_doc =  json_file(:collection_root)

    stub_request(:get, "https://api.pmp.io/").
      with(:headers => {'Accept'=>'application/vnd.pmp.collection.doc+json', 'Content-Type'=>'application/vnd.pmp.collection.doc+json', 'Host'=>'api.pmp.io:443'}).
      to_return(:status => 200, :body => root_doc, :headers => {})

    @root = @pmp.root
    @root.creator.must_be_instance_of PMP::Link
  end

  it "creates profile uri for type" do
    @pmp.profile_href_for_type('foo').must_equal("https://api.pmp.io/profiles/foo")
  end

  it "makes a doc of a profile type" do
    user = @pmp.doc_of_type('user')
    user.links['profile'].href.must_equal "https://api.pmp.io/profiles/user"
  end

end
