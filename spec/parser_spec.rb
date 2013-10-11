# -*- encoding: utf-8 -*-

require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

require 'ostruct'

require 'pmp/parser'

class TestParser < OpenStruct
  include PMP::Parser
end

describe PMP::Parser do

  it "will not parse nil document" do
    tc = TestParser.new
    tc.parse(nil)
  end

end
