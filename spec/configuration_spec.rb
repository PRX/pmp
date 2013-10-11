# -*- encoding: utf-8 -*-

require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

require 'pmp/configuration'

class TestConfiguration
  include PMP::Configuration

  def initialize(options={})
    apply_configuration(options)
  end
end

describe PMP::Configuration do

  before {
    @client_id     = ENV['PMP_API_KEY']    || "pmp-test-key"
    @client_secret = ENV['PMP_API_SECRET'] || "pmp-test-secret"
  }

  it "is initialized with defaults" do
    tc = TestConfiguration.new
    tc.options.wont_be_nil
    tc.options.keys.sort.must_equal PMP::Configuration::VALID_OPTIONS_KEYS.sort
    tc.options[:endpoint].must_equal PMP::Configuration::DEFAULT_ENDPOINT
  end

  it "can access configuration methods" do
    tc = TestConfiguration.new
    tc.endpoint.must_equal PMP::Configuration::DEFAULT_ENDPOINT
  end

  it "can change config and see reflected in options" do
    tc = TestConfiguration.new
    tc.endpoint.must_equal PMP::Configuration::DEFAULT_ENDPOINT
    tc.endpoint = 'test'
    tc.endpoint.must_equal 'test'
    tc.options[:endpoint].must_equal 'test'
  end

  it "is initialized with specific values" do
    tc = TestConfiguration.new(client_id: @client_id, client_secret: @client_secret)
    tc.options.wont_be_nil

    tc.options[:client_id].must_equal @client_id
    tc.client_id.must_equal @client_id

    tc.options[:client_secret].must_equal @client_secret
    tc.client_secret.must_equal @client_secret
  end

end
