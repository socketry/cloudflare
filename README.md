# CloudFlare

It is a Ruby wrapper for the CloudFlare API.

[![Build Status](https://secure.travis-ci.org/b4k3r/build-graph.png)](http://travis-ci.org/b4k3r/build-graph)

Official home page is [here](https://github.com/b4k3r/cloudflare). The complete [RDoc](http://rdoc.info/github/b4k3r/cloudflare/) is online.

Visit also a CloudFlare API documentation:

-    [Client](http://www.cloudflare.com/docs/client-api.html)
-    [Host](http://www.cloudflare.com/docs/host-api.html)

## Installation

Add this line to your application's Gemfile:

    gem 'cloudflare'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install cloudflare

## Usage

**Example for Client API:**

	require 'cloudflare'

	cf = CloudFlare::connection('user_api_key', 'user_email')

	begin
		cf.rec_new('domain.com', 'A', 'subdomain', '212.11.6.211', 1)
	rescue => e
		puts e.message # error message
	else
	  puts 'Successfuly added DNS record'
	end

**Example for Host API:**

	require 'cloudflare'

	cf = CloudFlare::connection('host_api_key')

	begin
		output = cf.create_user('john@example.com', 'secret', 'john')
	rescue => e
		puts e.message # error message
	else
		puts output['msg']
		puts "Your login is #{output['response']['cloudflare_username']}" # => john
	end

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request

## License

Released under the MIT license.

Copyright, 2012, 2014, by [Marcin Prokop](https://github.com/b4k3r).
Copyright, 2014, by [Samuel G. D. Williams](http://www.codeotaku.com/samuel-williams).

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
