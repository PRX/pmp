# -*- encoding: utf-8 -*-

require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

require 'pmp/links'


describe PMP::Links do

  before(:each) {
    @parent = Minitest::Mock.new    
    @links = PMP::Links.new(@parent)
  }

  it "can create a new links obj" do
    @links.wont_be_nil
  end

  it "can access _parent" do
    @links._parent = {}
    @links._parent.wont_be_nil
  end

  it "can have a link assigned" do
    link = {}
    @parent.expect(:foo=, link, Array(Object))
    @links['foo'] = link
    @links['foo'].must_equal link
  end

end