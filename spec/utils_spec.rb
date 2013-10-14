# -*- encoding: utf-8 -*-

require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

require 'pmp/utils'

class TestUtils
  include PMP::Utils
end

describe PMP::Utils do

  it "makes a name safe to assign as a method or attribute" do
    TestUtils.new.safe_name('what-is-this').must_equal 'what_is_this'
    TestUtils.new.safe_name('what--is-this').must_equal 'what_is_this'
    TestUtils.new.safe_name('-what--is-this').must_equal '_what_is_this'

    TestUtils.new.safe_name('?what-is-this').must_equal 'what_is_this'
    TestUtils.new.safe_name('what-is-this?').must_equal 'what_is_this?'
    TestUtils.new.safe_name('what?is?this?').must_equal 'what_is_this?'
  end

end
