#!/usr/bin/env ruby

require 'rubygems'
require 'bundler/setup'
require 'pmp'

# ------------------------------------------------------------------------------
# Setup: Make sure you can make a client with id and secret
# ------------------------------------------------------------------------------
client_id     = ENV['PMP_CLIENT_ID']
client_secret = ENV['PMP_CLIENT_SECRET']

raise "PMP_CLIENT_ID PMP_CLIENT_SECRET not set" unless client_id && client_secret

# doing this against the sandbox for now
endpoint = 'https://api-sandbox.pmp.io/'

# make a new client, assume id and secret are in the env
pmp = PMP::Client.new(client_id: client_id, client_secret: client_secret, endpoint: endpoint)


# ------------------------------------------------------------------------------
# Step 1: Make 3 orgs that will end up with different permissions
# ------------------------------------------------------------------------------
organizations = (0..2).map do |index|
  # make a new 'organization' of profile type user
  org = pmp.doc_of_type('user')

  org.title = "pmp ruby example, permissions: org #{index}"
  org.tags = ['pmp_example_permissions']
  org.auth = {
    user:     "pmp_ruby_org_#{index}",
    password: SecureRandom.uuid,
    scope:    'write'
  }
  org.save
  org
end
puts "Step 1 complete: organizations: #{organzations.to_json}\n\n"


# ------------------------------------------------------------------------------
# Step 2: Make 4 permission groups, 0:[0,1], 1:[0], 2:[1], and an empty group 3:[]
# ------------------------------------------------------------------------------
orgs = [ [0,1], [0], [1], [] ]
permission_groups = (0..2).map do |index|
  group = pmp.doc_of_type('group')
  group.tags = ['pmp_example_permissions']
  group.title = "pmp ruby example, permissions: permission group #{index}"
  group.links['item'] = orgs[index].map{|o| PMP::Link(href: organization[o].href)} if (orgs[index].size > 0)
  group.save
  group
end

puts "Step 2 complete: permission_groups: #{permission_groups.to_json}\n\n"
