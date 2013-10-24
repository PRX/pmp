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
  org       = pmp.doc_of_type('user')
  
  org.title = "pmp ruby example, permissions: org #{index}"
  org.tags  = ['pmp_example_permissions']
  org.auth  = {
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
group_orgs = [ [0,1], [0], [1], [] ]
permission_groups = group_orgs.collect do |orgs|
  group               = pmp.doc_of_type('group')
  group.tags          = ['pmp_example_permissions']
  group.title         = "pmp ruby example, permissions: permission group #{orgs.inspect}"
  group.links['item'] = orgs.map{|o| PMP::Link(href: organization[o].href)} if (orgs.size > 0)
  group.save
  group
end

puts "Step 2 complete: permission_groups: #{permission_groups.to_json}\n\n"

# ------------------------------------------------------------------------------
# Step 3: Make docs to be protected
# ------------------------------------------------------------------------------
documents = (0..3).collect do |index|
  doc = pmp.doc_of_type('story')
  doc.tags  = ['pmp_example_permissions']
  doc.title = "pmp ruby example, permissions: story #{index}"
end

documents[0].links['permission'] = { href: permission_groups[0].href, operation: 'read' }

documents[1].links['permission'] = [
  {
    href: permission_groups[2].href,
    operation: 'read',
    blacklist: true
  },
  {
    href: permission_groups[1].href,
    operation: 'read'
  },
]

documents[3].links['permission'] = { href: permission_groups[3].href, operation: 'read' }

documents.each{|d| d.save }


# ------------------------------------------------------------------------------
# Step 4: Make credentials for each org
# ------------------------------------------------------------------------------
credentials = organizations.map do |org|
  pmp.credentials.create(user: org.auth['user'], password: org.auth['password'])
end
