# -*- encoding: utf-8 -*-

require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

require 'pmp/token'

require 'webmock/minitest'

describe PMP::Token do

  it "gets the base path for this subclass of API" do
    token = PMP::Token.new
    token.token_url.must_equal '/auth/access_token'
  end

  it "gets an access_token" do
    access_token = "thisisnotanaccesstokenno"
    response_body = {
      access_token: access_token,
      token_type: "Bearer",
      token_issue_date: DateTime.now,
      token_expires_in: 24*60*60
    }.to_json
                            
    stub_request(:post, "https://api-sandbox.pmp.io/auth/access_token").
      with(:body => {"grant_type"=>"client_credentials"},
           :headers => {'Accept'=>'application/json', 'Authorization'=>'Basic dGhpc2lzbm90YS1yZWFsLWNsaWVudC1pZC1zb3Zlcnlzb3JyeTp0aGlzaXNub3RhcmVhbHNlY3JldGVpdGhlcg==', 'Content-Type'=>'application/x-www-form-urlencoded', 'Host'=>'api-sandbox.pmp.io:443'}).
      to_return(:status => 200, :body => response_body, :headers => {'Content-Type' => 'application/json; charset=utf-8'})

    client_id = "thisisnota-real-client-id-soverysorry"
    client_secret = "thisisnotarealsecreteither"
    endpoint = "https://api-sandbox.pmp.io"
    token_path = '/auth/access_token'
    
    token_api= PMP::Token.new(client_id: client_id, client_secret: client_secret, endpoint: endpoint)
    token = token_api.get_token
    token.token.must_equal access_token
    token.params['token_type'].must_equal 'Bearer'
  end

end
