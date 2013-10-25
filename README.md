# PMP (Public Media Platform)

[![Build Status](https://travis-ci.org/PRX/pmp.png)](https://travis-ci.org/PRX/pmp)
[![Coverage Status](https://coveralls.io/repos/PRX/pmp/badge.png)](https://coveralls.io/r/PRX/pmp)
[![Code Climate](https://codeclimate.com/github/PRX/pmp.png)](https://codeclimate.com/github/PRX/pmp)
[![Dependency Status](https://gemnasium.com/PRX/pmp.png)](https://gemnasium.com/PRX/pmp)
[![Gem Version](https://badge.fury.io/rb/pmp.png)](http://badge.fury.io/rb/pmp)

Gem to make it easier to use the PMP (Public Media Platform) API, which is a hypermedia API using the collection.doc+json format.

You can learn more about the PMP here:

https://github.com/publicmediaplatform/pmpdocs/wiki



## Installation

Add this line to your application's Gemfile:

    gem 'pmp'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install pmp

## Usage

You should usually go through the `PMP::Client` as a convenience or start with a `PMP::CollectionDocument`.

Below is a basic guide, you can also [see the examples for more info](example/).


```ruby

# so you need a few things, like the endpoint, but default is "https://api.pmp.io"
endpoint = "https://api-sandbox.pmp.io"

# and you need credentials, the gem doesn't help you create these (yet)
client_id = "thisisnota-real-client-id-soverysorry"
client_secret = "thisisnotarealsecreteither"

# construct the client, setting some config in there
# this will automatically get a token as there is not one set
pmp = PMP::Client.new(client_id: client_id, client_secret: client_secret, endpoint: endpoint)

# or if you have a token already
token = 'thisisnotatoken'
pmp = PMP::Client.new(oauth_token: token, endpoint: endpoint)

# or if you want to get a token
pmp = PMP::Client.new(client_id: client_id, client_secret: client_secret, endpoint: endpoint)
oauth_token = pmp.token

# get the token string out of the token response
puts oauth_token.token
> 'thisisnotatoken'

# so let's get the root doc - an PMP::CollectionDocument instance
root = pmp.root

# or we can get it without the client, since PMP::CollectionDocument defaults to root
root = PMP::CollectionDocument.new(oauth_token: token, endpoint: endpoint)

# wanna get an attribute, act like it is a ruby attribute
puts root.guid
> '04224975-e93c-4b17-9df9-96db37d318f3'

# want to get the links, you can get a list of them by the rels
puts root.links.keys.sort
> ["creator", "edit", "navigation", "query"]

# don't feel like getting root first? Methods on the client get passed on to root
puts pmp.links.keys.sort
> ["creator", "edit", "navigation", "query"]

# want to get the creator link?
puts pmp.links["creator"]
> #<PMP::Link href="https://api-sandbox.pmp.io/docs/af676335-21df-4486-ab43-e88c1b48f026">

# get the same thing as a method
puts pmp.creator
> #<PMP::Link href="https://api-sandbox.pmp.io/docs/af676335-21df-4486-ab43-e88c1b48f026">

# like the root doc itself, this is lazy loaded
# but ask for an attribute on there, and you'll get the doc loaded up
puts pmp.creator.guid

#### http get request to link href occurs, loads info about the creator
> 'af676335-21df-4486-ab43-e88c1b48f026'

```

## Saving and Deleting

Once you have a doc, you can save or delete it like so:

```ruby
# create a new blank doc, will generatr a guid automatically if not present
doc = PMP::CollectionDocument.new()
doc.title = "this is an example, ok?"
doc.save

# get that guid!
guid = doc.guid

# how about the link to self
self_href = doc.self.href

# get a new doc using self, could just have used the link, this is a bad example perhaps
doc = PMP::CollectionDocument.new(href: self_href)

# update an existing attribute
doc.title = "this is another awesome example, cool?"

# can add an attribute (doesn't check schema yet)
doc.adding_an_attribute = "this will get saved as a new attribute adding-an-attribute"

# can add links (doesn't check schema yet)
doc.links['some-new-link'] = PMP::Link.new({href:'http://somenewlink.io'})
new_link = doc.some_new_link

# save changes
doc.save

# never mind, delete it
doc.delete
```

# Credits

Very big hat tip to the hyperresource gem: https://github.com/gamache/hyperresource

## To Do

Think about integrating this lovely json schema parsing project: https://github.com/google/autoparse

or this one: https://github.com/hoxworth/json-schema

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
