# Cloudflare

It is a Ruby wrapper for the Cloudflare V4 API. It provides a light weight wrapper using `RestClient::Resource`. The wrapper functionality is limited to zones and DNS records at this time, *PRs welcome*.

[![Build Status](https://secure.travis-ci.org/ioquatix/cloudflare.svg)](http://travis-ci.org/ioquatix/cloudflare)

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

Prepare a connection to the remote API:

```ruby
require 'cloudflare'

# Grab some details from somewhere:
email = ENV['CLOUDFLARE_EMAIL']
key = ENV['CLOUDFLARE_KEY']

# Set up the connection:
connection = Cloudflare.connect(key: key, email: email)
```

Get all available zones:

```ruby
zones = connection.zones.all
```

Get a specific zone:

```ruby
zone = connection.zones.find_by_id("...")
zone = connection.zones.find_by_name("example.com")
```

Get DNS records for a given zone:

```ruby
dns_records = zones.first.dns_records.all
```

Show some details of the DNS record:

```ruby
dns_record = records.first
puts records.first.record[:name]
puts records
```

Get firewall rules:

``` ruby
all_rules =  zones.first.firewall_rules.all
block_rules = zones.first.firewall_rules.all("block")  # or "whitelist" or "challenge"
```

Get blocked ips:

``` ruby
block_rules = zones.first.firewall_rules.all("block") 
blocked_ips = zones.first.firewall_rules.firewalled_ips(block_rules)
```

Block an ip:

``` ruby
# ip = "nnn.nnn.nnn.nnn"
# note: "some note about the block"
data = {"mode":"block","configuration":{"target":"ip","value":"#{ip}"},"notes":"#{note} #{Time.now.strftime("%m/%d/%y")} "}
response = zones.first.firewall_rules.post(data.to_json, content_type: 'application/json')

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

Copyright, 2012, 2014, by [Marcin Prokop](https://github.com/b4k3r).
Copyright, 2017, by [Samuel G. D. Williams](http://www.codeotaku.com/samuel-williams).

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



