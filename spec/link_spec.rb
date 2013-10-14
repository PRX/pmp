# -*- encoding: utf-8 -*-

require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

require 'pmp/link'

require 'webmock/minitest'

describe PMP::Link do

  it "can create a new link" do
    parent = Minitest::Mock.new
    info = {}
    link = PMP::Link.new(parent, info)
    link.wont_be_nil
  end

  it "can save params to attributes" do
    parent = Minitest::Mock.new
    info = {'href' => 'http://api-sandbox.pmp.io/docs/'}
    link = PMP::Link.new(parent, info)
    link.href.must_equal 'http://api-sandbox.pmp.io/docs/'
  end

  it "can retrieve link resource" do
    parent = Minitest::Mock.new
    info = {'href' => 'http://api-sandbox.pmp.io/docs/'}
    link = PMP::Link.new(parent, info)
    link.href.must_equal 'http://api-sandbox.pmp.io/docs/'
  end

  it "can become json" do
    parent = Minitest::Mock.new
    info = {'href' => 'http://api-sandbox.pmp.io/docs/'}
    link = PMP::Link.new(parent, info)
  end

end
