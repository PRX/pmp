# -*- encoding: utf-8 -*-

require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

require 'pmp/links'


describe PMP::Links do

  before(:each) {
    @parent = PMP::CollectionDocument.new
    @links = PMP::Links.new(@parent)
    @parent.links = @links
  }

  it "can create a new links obj" do
    @links.wont_be_nil
  end

  it "can access _parent" do
    @links.parent = {}
    @links.parent.wont_be_nil
  end

  it "can have a link assigned" do
    link = {}
    @links['foo'] = link
    @links['foo'].must_equal link
    @parent.foo.must_equal link
  end

end
