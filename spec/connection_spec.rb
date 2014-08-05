# -*- encoding: utf-8 -*-

require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

require 'pmp/configuration'

class TestConnection
  include PMP::Connection
end

describe PMP::Connection do

  before {
    @tc = TestConnection.new
  }

  it "sets default connection options" do
    opts = @tc.process_options
    opts.wont_be_nil
  end

  it "sets default connection options" do
    opts = @tc.process_options(endpoint:'endpoint')
    opts[:ssl].must_equal({:verify => false})
    opts[:url].must_equal 'endpoint'
  end

  it "mereges headers for connection options" do
    opts = @tc.process_options(user_agent:'user_agent', headers:{foo:'bar'})
    opts[:headers][:foo].must_equal 'bar'
    opts[:headers]['User-Agent'].must_equal 'user_agent'
    opts[:headers]['Accept'].must_equal "application/vnd.collection.doc+json"
  end

end
