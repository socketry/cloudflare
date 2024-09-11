# Cloudflare

It is a Ruby wrapper for the Cloudflare V4 API. It provides a light weight wrapper using `RestClient::Resource`. The wrapper functionality is limited to zones and DNS records at this time, *PRs welcome*.

[![Development Status](https://github.com/socketry/cloudflare/workflows/Test/badge.svg)](https://github.com/socketry/cloudflare/actions?workflow=Test)

## Installation

Add this line to your application's Gemfile:

``` ruby
gem 'cloudflare'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install cloudflare

## Usage

Here are some basic examples. For more details, refer to the code and specs.

``` ruby
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

``` ruby
require 'cloudflare'

token = 'a_generated_api_token'

Cloudflare.connect(token: token) do |connection|
	# ...
end
```

### Using with Async

``` ruby
Async do
	connection = Cloudflare.connect(...)
	
	# ... do something with connection ...
ensure
	connection.close
end
```

## Contributing

We welcome contributions to this project.

1.  Fork it.
2.  Create your feature branch (`git checkout -b my-new-feature`).
3.  Commit your changes (`git commit -am 'Add some feature'`).
4.  Push to the branch (`git push origin my-new-feature`).
5.  Create new Pull Request.

### Developer Certificate of Origin

In order to protect users of this project, we require all contributors to comply with the [Developer Certificate of Origin](https://developercertificate.org/). This ensures that all contributions are properly licensed and attributed.

### Community Guidelines

This project is best served by a collaborative and respectful environment. Treat each other professionally, respect differing viewpoints, and engage constructively. Harassment, discrimination, or harmful behavior is not tolerated. Communicate clearly, listen actively, and support one another. If any issues arise, please inform the project maintainers.

## See Also

  - [Cloudflare::DNS::Update](https://github.com/ioquatix/cloudflare-dns-update) - A dynamic DNS updater based on this gem.
  - [Rubyflare](https://github.com/trev/rubyflare) - Another implementation.
