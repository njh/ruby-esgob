[![Build Status](https://travis-ci.org/njh/ruby-esgob.svg)](https://travis-ci.org/njh/ruby-esgob)

Esgob Ruby Client
=================

[Esgob Ltd] operate an [international network] of anycast servers.
Their [Secondary DNS] service is available for free.
This Ruby Gem provides convenient access to the [Esgob API].


## Installation

Add this line to your application's Gemfile:

```ruby
gem 'esgob'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install esgob

## Usage

First create a new client instance, by passing in your account name and API key:

    esgob = Esgob::Client.new('account', 'key')

Alternatively, as it is often desirable to keep secrets outside of the source code, it is also possible to pass in the account name and API key using environment variables set in the shell:

    export ESGOB_ACCOUNT=accountname
    export ESGOB_API_KEY=4472ed80e0f511e4aee13c0754043581

The client instance can then be initialised without passing any arguments:

    esgob = Esgob::Client.new


Add a new slave domain, passing in the domain and the master DNS server to fetch the zone from:

    esgob.domains_slaves_add('example.org', '192.168.0.1')

Get a list of the registered slave domains:

    domains = esgob.domains_slaves_list

Here is an example of what can be done in an IRB session:

    $ irb -resgob
    irb(main):001:0> esgob = Esgob::Client.new
    => #<Esgob::Client:0x007fd2e3b13420>
    irb(main):002:0> esgob.domains_slaves_list
    => {"example.com"=>"192.168.0.1", "example.uk"=>"192.168.0.1"}
    irb(main):003:0> esgob.domains_slaves_list.keys
    => ["example.com", "example.uk"]
    irb(main):004:0> 

See the [API documentation] for full details.


## More information

* https://noc.esgob.com/secondary_dns
* https://noc.esgob.com/docs/api

## Contributing

1. Fork it ( https://github.com/njh/esgob/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request


[Esgob Ltd]:              https://www.esgob.com/
[Esgob API]:              https://noc.esgob.com/docs/api
[international network]:  https://noc.esgob.com/status/anycast_instances
[Secondary DNS]:          https://noc.esgob.com/secondary_dns

[API documentation]:      http://www.rubydoc.info/gems/esgob
