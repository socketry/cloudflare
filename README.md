CloudFlare
==========

It is a Ruby wrapper for the CloudFlare API.

Official home page is [here](https://github.com/b4k3r/cloudflare). The complete [RDoc](http://rdoc.info/github/b4k3r/cloudflare/) is online.

Visit also a CloudFlare API documentation:

-    [Client](http://www.cloudflare.com/docs/client-api.html)
-    [Host](http://www.cloudflare.com/docs/host-api.html)

Installation
------------

```
gem install cloudflare
```

Or, if use Rails, include the gem in your Gemfile:

```
gem 'cloudflare'
```

Usage
-----

**Example for Client API:**

```
require 'cloudflare'

cf = CloudFlare::connection('user_api_key', 'user_email')

begin
	cf.rec_new('domain.com', 'A', 'subdomain', '212.11.6.211', 1)
rescue => e
	puts e.message # error message
else
  puts 'Successfuly added DNS record'
end
```

**Example for Host API:**

```
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
```

License
-------

Copyright &copy; 2012 - 2014. It is free software, and may be redistributed under the terms specified in the MIT-LICENSE file.

