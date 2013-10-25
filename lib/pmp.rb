# -*- encoding: utf-8 -*-

require 'rubygems'
require 'active_support/all'

require 'pmp/version'

require 'pmp/utils'
require 'pmp/configuration'
require 'pmp/connection'
require 'pmp/response'
require 'pmp/parser'

require 'pmp/links'
require 'pmp/link'
require 'pmp/collection_document'

require 'pmp/token'
require 'pmp/credential'
require 'pmp/client'

module PMP
  extend Configuration
end
