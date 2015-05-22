[![Build Status](https://travis-ci.org/njh/ruby-esgob.svg)](https://travis-ci.org/njh/ruby-esgob)

Esgob Ruby Client
=================

[Esgob Ltd] operate an [international network] of anycast servers.
Their [Secondary DNS] service is available for free.
This Ruby Gem provides convenient access to the [Esgob API] via a command line tool
and Ruby library.


## Installation

Install it as a gem using:

    $ gem install esgob

Or add this line to your application's Gemfile:

```ruby
gem 'esgob'
```

And then execute:

    $ bundle


## Command Line Usage

Without any arguments, the ```esgob``` tool will display a list of commands:

```
Commands:
  esgob account                        # Display account info
  esgob config                         # Save the Esgob account and key
  esgob domains                        # List all domains
  esgob help [COMMAND]                 # Describe available commands or one specific command
  esgob slaves                         # List slave domains
  esgob slaves-add DOMAIN MASTERIP     # Add new slave domain
  esgob slaves-delete DOMAIN           # Delete a slave domain
  esgob slaves-sync FILE MASTERIP      # Synronises list of slave domains in a file
  esgob slaves-transfer DOMAIN         # Force transfer from master of a slave domain
  esgob slaves-update DOMAIN MASTERIP  # Updates the master IP of a slave domain
  esgob soacheck DOMAIN                # Fetch domain SOA serial number for all nodes
  esgob version                        # Show Esgob Ruby Client version

Options:
  -a, [--account=Account Name]     
  -k, [--key=API Key]              
  -v, [--verbose], [--no-verbose]  
```

To configure the client with some credentials use the ```esgob config``` command:

```
$ esgob config
What is your Esgob account name? accountname
What is your Esgob key? 4472ed80e0f511e4aee13c0754043581
Configuration written to /home/username/.esgob
```



## Library Usage

First create a new client instance, by passing in your account name and API key:

    esgob = Esgob::Client.new('account', 'key')

Alternatively, as it is often desirable to keep secrets outside of the source code,
it is also possible to pass in the account name and API key using a configuration file.
The following paths are searched in the following order:

    ~/.esgob
    /usr/local/etc/esgob.conf
    /etc/esgob.conf

The configuration file should be in the format:

    account some_account_name
    key kskjhdkjdhkjhdkjdhdkjhdkjhd

Or set using environment variables:

    export ESGOB_ACCOUNT=accountname
    export ESGOB_KEY=4472ed80e0f511e4aee13c0754043581

The client instance can then be initialised without passing any arguments:

    esgob = Esgob::Client.new


Add a new slave domain, passing in the domain and the master DNS server to fetch the zone from:

    esgob.domains_slaves_add('example.org', '192.168.0.1')

Get a list of the registered slave domains:

    domains = esgob.domains_slaves_list

Here is an example of what can be done in an IRB session:

    $ irb -resgob
    irb(main):001:0> esgob = Esgob::Client.new
    => #<Esgob::Client account=myacct>
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


## License

The esgob ruby gem is licensed under the terms of the MIT license.
See the file LICENSE for details.


## Contact

* Author:    Nicholas J Humfrey
* Email:     njh@aelius.com
* Twitter:   [@njh]
* Home Page: http://www.aelius.com/njh/


[@njh]:                   http://twitter.com/njh

[Esgob Ltd]:              https://www.esgob.com/
[Esgob API]:              https://noc.esgob.com/docs/api
[international network]:  https://noc.esgob.com/status/anycast_instances
[Secondary DNS]:          https://noc.esgob.com/secondary_dns

[API documentation]:      http://www.rubydoc.info/gems/esgob
