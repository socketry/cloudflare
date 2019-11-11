# Cloudflare

It is a Ruby wrapper for the Cloudflare V4 API. It provides a light weight wrapper using `RestClient::Resource`. The wrapper functionality is limited to zones and DNS records at this time, *PRs welcome*.

[![Build Status](https://secure.travis-ci.org/socketry/cloudflare.svg)](http://travis-ci.org/socketry/cloudflare)
[![Coverage Status](https://coveralls.io/repos/socketry/cloudflare/badge.svg)](https://coveralls.io/r/socketry/cloudflare)

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'cloudflare'
```

And then execute:

```
$ bundle
```

Or install it yourself as:

```
$ gem install cloudflare
```

## Usage

Here are some basic examples. For more details, refer to the code and specs.

```ruby
require 'cloudflare'

# Grab some details from somewhere:
email = ENV['CLOUDFLARE_EMAIL']
key = ENV['CLOUDFLARE_KEY']

Cloudflare.connect(key: key, email: email) do |connection|
	# Get all available zones:
	zones = connection.zones
	
	# Get a specific zone:
	zone = connection.zones.find_by_id("...")
	zone = connection.zones.find_by_name("example.com")
	
	# Get DNS records for a given zone:
	dns_records = zone.dns_records
	
	# Show some details of the DNS record:
	dns_record = dns_records.first
	puts dns_record.name
	
	# Add a DNS record. Here we add an A record for `batman.example.com`:
	zone = zones.find_by_name("example.com")
	zone.dns_records.create('A', 'batman', '1.2.3.4', proxied: false)
	
	# Get firewall rules:
	all_rules = zone.firewall_rules
	
	# Block an ip:
	rule = zone.firewall_rules.set('block', '1.2.3.4', notes: "ssh dictionary attack")
end
```

### Using a Bearer Token

You can read more about [bearer tokens here](https://blog.cloudflare.com/api-tokens-general-availability/). This allows you to limit priviledges.

```ruby
require 'cloudflare'

token = 'a_generated_api_token'

Cloudflare.connect(token: token) do |connection|
	# ...
end
```

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request

## See Also

- [Cloudflare::DNS::Update](https://github.com/ioquatix/cloudflare-dns-update) - A dynamic DNS updater based on this gem.
- [Rubyflare](https://github.com/trev/rubyflare) - Another implementation.

## License

Released under the MIT license.

Copyright, 2018, by [Samuel G. D. Williams](http://www.codeotaku.com/samuel-williams).  
Copyright, 2017, by [David Rosenbloom](http://artifactory.com).  
Copyright, 2012, 2014, by [Marcin Prokop](https://github.com/b4k3r).  

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.
