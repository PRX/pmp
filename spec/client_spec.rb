# -*- encoding: utf-8 -*-

require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe PMP::Client do

  before(:each) {
    @pmp = PMP::Client.new
  }

  it "returns a root api object" do
    @pmp = PMP::Client.new
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

end
