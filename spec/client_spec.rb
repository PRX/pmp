# -*- encoding: utf-8 -*-

require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe PMP::Client do

  it "returns a root api object" do
    pmp = PMP::Client.new
    pmp.root.wont_be_nil
  end

end
