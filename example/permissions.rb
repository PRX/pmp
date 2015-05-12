#!/usr/bin/env ruby
# ruby version of https://github.com/APMG/pmp-sdk-perl/blob/master/t/002-authz.t

require 'rubygems'
require 'bundler/setup'
require 'pmp'
require 'json'

# some utility methods
def waiting(seconds, message="waiting")
  print message
  seconds.to_i.times{ print "."; sleep(1) }
  print "\n"
end

def pretty_json(s)
  JSON.pretty_generate(JSON.parse(s))
end

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
puts "\n\nSetup complete: pmp client: #{pmp.inspect}\n\n"

# ------------------------------------------------------------------------------
# Step 0: Clean up any old data from prior runs
# ------------------------------------------------------------------------------
delete_count = 0
pmp.query["urn:collectiondoc:query:docs"].where(tag: 'pmp_example_permissions', limit: 100).items.each{|i| i.delete; delete_count+=1 }
puts "\n\nStep 0 complete: deleted #{delete_count}\n\n"
exit 1 if ARGV[0] == 'delete-only'

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
puts "\n\nStep 1 complete: organizations: #{pretty_json(organizations.to_json)}\n\n"

# ------------------------------------------------------------------------------
# Step 2: Make 4 permission groups, 0:[0,1], 1:[0], 2:[1], and an empty group 3:[]
# ------------------------------------------------------------------------------
group_orgs = [ [0,1], [0], [1], [] ]
permission_groups = group_orgs.collect do |orgs|
  group               = pmp.doc_of_type('group')
  group.tags          = ['pmp_example_permissions']
  group.title         = "pmp ruby example, permissions: permission group #{orgs.inspect}"
  group.links['item'] = orgs.map{|o| PMP::Link.new(href: organizations[o].href)} if (orgs.size > 0)
  group.save
  group
end
puts "\n\nStep 2 complete: permission_groups: #{pretty_json(permission_groups.to_json)}\n\n"

# ------------------------------------------------------------------------------
# Step 3: Make docs to be protected
# ------------------------------------------------------------------------------
documents = (0..3).collect do |index|
  doc = pmp.doc_of_type('story')
  doc.tags  = ['pmp_example_permissions', 'pmp_example_permissions_test_doc']
  doc.title = "pmp ruby example, permissions: story #{index}"
  doc
end

documents[0].links['permission'] = PMP::Link.new(href: permission_groups[0].href, operation: 'read')

documents[1].links['permission'] = [
  PMP::Link.new(
    href: permission_groups[2].href,
    operation: 'read',
    blacklist: true
  ),
  PMP::Link.new(
    href: permission_groups[1].href,
    operation: 'read'
  ),
]

documents[3].links['permission'] = PMP::Link.new(href: permission_groups[3].href, operation: 'read')

documents.each{|d| d.save }

puts "\n\nStep 3 complete: documents: #{pretty_json(documents.to_json)}\n\n"

# ------------------------------------------------------------------------------
# Step 4: Make credentials and clients for each org
# ------------------------------------------------------------------------------
credentials = organizations.map do |org|
  puts "create credentials for org: #{org.auth}"
  pmp.credentials(user: org.auth[:user], password: org.auth[:password]).create
end

waiting(5)

clients = credentials.map do |creds|
  PMP::Client.new(client_id: creds['client_id'], client_secret: creds['client_secret'], endpoint: endpoint)
end
puts "\n\nStep 4 complete: credentials: #{pretty_json(credentials.to_json)}\n\n"

# ------------------------------------------------------------------------------
# Step 5: Test doc visibility!
# ------------------------------------------------------------------------------
puts "\n\nStep 5: TEST TIME!\n\n"
results = (0..2).collect do |index|
  expected_size = (3 - index)
  puts "org #{index} should retrieve #{expected_size} items"

  puts "org #{index} got token: #{clients[index].token.token}"
  waiting(5)
  
  result = clients[index].query["urn:pmp:query:docs"].where(tag: 'pmp_example_permissions_test_doc').retrieve
  actual_size = result.items.size
  msg = (actual_size == expected_size) ? "SUCCESS" : "FAIL"
  puts "#{msg}: org #{index} retrieved #{actual_size} items, expected #{expected_size}.\n"
  puts "retrieved: #{pretty_json(result.to_json)}\n\n"

  result
end

puts "\n\nStep 5 complete, all done!\n\n"

exit 1
