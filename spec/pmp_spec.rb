# -*- encoding: utf-8 -*-

require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe PMP do

  it "has default configuration" do
    PMP.options.wont_be_nil
    PMP.options[:endpoint].must_equal "https://api.pmp.io/"
  end

end
