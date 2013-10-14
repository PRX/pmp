# -*- encoding: utf-8 -*-

require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

require 'pmp/utils'

class TestUtils
  include PMP::Utils
end

describe PMP::Utils do

  it "makes a name safe to assign as a method or attribute" do
    utils = TestUtils.new

    utils.to_ruby_safe_name('what-is-this').must_equal 'what_is_this'
    utils.to_ruby_safe_name('what--is-this').must_equal 'what_is_this'
    utils.to_ruby_safe_name('-what--is-this').must_equal '_what_is_this'

    utils.to_ruby_safe_name('?what-is-this').must_equal 'what_is_this'
    utils.to_ruby_safe_name('what-is-this?').must_equal 'what_is_this?'
    utils.to_ruby_safe_name('what?is?this?').must_equal 'what_is_this?'
  end

  it "turns ruby name into json key" do
    utils = TestUtils.new
    utils.to_json_key_name('what_is_this').must_equal 'what-is-this'
  end

  it "should round trip common json keys" do
    utils = TestUtils.new
    utils.to_json_key_name(utils.to_ruby_safe_name('edit-form')).must_equal 'edit-form'
  end

end
