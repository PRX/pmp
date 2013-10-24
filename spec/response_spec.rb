# -*- encoding: utf-8 -*-

require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

require 'ostruct'

require 'pmp/response'

describe PMP::Response do

  before {
    @raw = Minitest::Mock.new
    @raw.expect(:status, 200)
    @request = {}
  }

  it "can make a new response" do
    response = PMP::Response.new(@raw, @request)
  end

  it "can raise an error" do
    raw = Minitest::Mock.new
    raw.expect(:status, 500).expect(:status, 500)
    proc{ PMP::Response.new(raw, @request) }.must_raise RuntimeError

    raw = Minitest::Mock.new
    raw.expect(:status, 600).expect(:status, 600)
    proc{ PMP::Response.new(raw, @request) }.must_raise RuntimeError
  end

  it "can return body" do
    @raw.expect(:body, {foo: 'bar'})
    response = PMP::Response.new(@raw, @request)
    response.body[:foo].must_equal 'bar'
  end

end
