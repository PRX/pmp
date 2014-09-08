# -*- encoding: utf-8 -*-

require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe PMP::Client do

  before do
    @pmp = PMP::Client.new(oauth_token: 'thisisatestvalueonly')
    @root_doc = json_file(:collection_root)
  end

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
    stub_request(:get, 'https://api.pmp.io').to_return(:status => 200, :body => @root_doc)
    @root = @pmp.root
    @root.creator.first.must_be_instance_of PMP::Link
  end

  it "calls the root doc when client does not have method" do
    stub_request(:get, 'https://api.pmp.io').to_return(:status => 200, :body => @root_doc)
    @pmp.creator.first.must_be_instance_of PMP::Link
  end


  it "gets a credentials object" do
    @pmp.credentials.wont_be_nil
  end

  it "gets a token object" do

    access_token = "thisisnotanaccesstokenno"
    response_body = {
      access_token: access_token,
      token_type: "Bearer",
      token_issue_date: DateTime.now,
      token_expires_in: 24*60*60
    }.to_json

    stub_request(:post, "https://api.pmp.io/auth/access_token").
      with(:body => {"grant_type"=>"client_credentials"},
           :headers => {'Accept'=>'application/json', 'Authorization'=>'Basic dGhpc2lzbm90YS1yZWFsLWNsaWVudC1pZC1zb3Zlcnlzb3JyeTp0aGlzaXNub3RhcmVhbHNlY3JldGVpdGhlcg==', 'Content-Type'=>'application/x-www-form-urlencoded'}).
      to_return(:status => 200, :body => response_body, :headers => {'Content-Type' => 'application/json; charset=utf-8'})

    stub_request(:get, 'https://api.pmp.io').to_return(:status => 200, :body => @root_doc)

    client_id = "thisisnota-real-client-id-soverysorry"
    client_secret = "thisisnotarealsecreteither"

    pmp = PMP::Client.new(client_id: client_id, client_secret: client_secret)

    pmp.token.wont_be_nil
  end

  it "creates profile uri for type" do
    @pmp.profile_href_for_type('foo').must_equal("https://api.pmp.io/profiles/foo")
  end

  it "makes a doc of a profile type" do
    user = @pmp.doc_of_type('user')
    user.links['profile'].href.must_equal "https://api.pmp.io/profiles/user"
  end

end
