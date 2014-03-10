# Copyright, 2012, by Marcin Prokop.
# 
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
# 
# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.
# 
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
# THE SOFTWARE.

require 'net/http'
require 'json'

# For more information please visit:
# - http://www.cloudflare.com/docs/client-api.html
# - http://www.cloudflare.com/docs/host-api.html
#
module CloudFlare
	class RequestError < StandardError
		def initialize(what, response)
			super(what)
			
			@response = response
		end
		
		attr :response
	end
	
	class Connection
		# URL for Client and Host API
		URL_API = {
			client: 'https://www.cloudflare.com/api_json.html',
			host: 'https://api.cloudflare.com/host-gw.html'
		}

		TIMEOUT = 5 # Default is 5 seconds

		# @param api_key [String] user or Host API key.
		# @param email [String] it is for a Client API.
		def initialize(api_key, email = nil)
			@params = Hash.new

			if email.nil?
				@params[:api_key] = api_key
			else
				@params[:api_key] = api_key
				@params[:email] = email
			end

		end

		# CLIENT

		# This function can be used to get currently settings of values such as the security level.
		#
		# @see http://www.cloudflare.com/docs/client-api.html#s3.1
		#
		# @param zone [String]
		# @param interval [Integer]

		def stats(zone, interval = 20)
			send_req({a: :stats, z: zone, interval: interval})
		end

		# This function lists all domains in a CloudFlare account along with other data.
		#
		# @see http://www.cloudflare.com/docs/client-api.html#s3.2

		def zone_load_multi
			send_req(a: :zone_load_multi)
		end

		# This function lists all of the DNS records from a particular domain in a CloudFlare account.
		#
		# @see http://www.cloudflare.com/docs/client-api.html#s3.3
		#
		# @param zone [String]

		def rec_load_all(zone)
			send_req({a: :rec_load_all, z: zone})
		end

		# This function checks whether one or more websites/domains are active under an account and return the zone ids (zids) for these.
		#
		# @see http://www.cloudflare.com/docs/client-api.html#s3.4
		#
		# @param zones [String or Array] 

		def zone_check(*zones)
			send_req({a: :zone_check, zones: zones.kind_of?(Array) ? zones.join(',') : zones})
		end

		# This function pulls recent IPs hitting your site.
		#
		# @see http://www.cloudflare.com/docs/client-api.html#s3.5
		#
		# @param zone [String]
		# @param hours [Integer] max 48
		# @param classification [String] (optional) values: r|c|t
		# @param geo [Fixnum] (optional)

		def zone_ips(zone, classification = nil, hours = 24, geo = 1)
			send_req({a: :zone_ips, z: zone, hours: hours, "class" => classification, geo: geo})
		end

		# This function checks the threat score for a given IP.
		#
		# @see http://www.cloudflare.com/docs/client-api.html#s3.6
		#
		# @param ip [String]

		def ip_lkup(ip)
			send_req({a: :ip_lkup, ip: ip})
		end

		# This function retrieves all current settings for a given domain.
		#
		# @see http://www.cloudflare.com/docs/client-api.html#s3.7
		#
		# @param zone [String]

		def zone_settings(zone)
			send_req({a: :zone_settings, z: zone})
		end

		# This function sets the Basic Security Level to HELP I'M UNDER ATTACK / HIGH / MEDIUM / LOW / ESSENTIALLY OFF.
		#
		# @see http://www.cloudflare.com/docs/client-api.html#s4.1
		#
		# @param zone [String]
		# @param value [String] values: low|med|high|help|eoff

		def sec_lvl(zone, value)
			send_req({a: :sec_lvl, z: zone, v: value})
		end

		# This function sets the Caching Level to Aggressive or Basic.
		#
		# @see http://www.cloudflare.com/docs/client-api.html#s4.2
		#
		# @param zone [String]
		# @param value [String] values: agg|basic

		def cache_lvl(zone, value)
			send_req({a: :cache_lvl, z: zone, v: value})
		end

		# This function allows you to toggle Development Mode on or off for a particular domain.
		#
		# @see http://www.cloudflare.com/docs/client-api.html#s4.3
		#
		# @param zone [String]
		# @param value [Boolean] 

		def devmode(zone, value)
			send_req({a: :devmode, z: zone, v: value ? 1 : 0})
		end

		# This function will purge CloudFlare of any cached files.
		#
		# @see http://www.cloudflare.com/docs/client-api.html#s4.4
		#
		# @param zone [String]

		def fpurge_ts(zone)
			send_req({a: :fpurge_ts, z: zone, v: 1})
		end

		# This function will purge a single file from CloudFlare's cache.
		#
		# @see http://www.cloudflare.com/docs/client-api.html#s4.5
		#
		# @param zone [String]
		# @param url [String]

		def zone_file_purge(zone, url)
			send_req({a: :zone_file_purge, z: zone, url: url})
		end

		# This function updates the snapshot of your site for CloudFlare's challenge page.
		#
		# @see http://www.cloudflare.com/docs/client-api.html#s4.6
		#
		# @param zoneid [Integer]

		def zone_grab(zoneid)
			send_req({a: :zone_grab, zid: zoneid})
		end

		# This function adds an IP address to your white lists.
		#
		# @see http://www.cloudflare.com/docs/client-api.html#s4.7
		#
		# @param ip [String]

		def whitelist(ip)
			send_req({a: :wl, key: ip})
		end


		# This function adds an IP address to your black lists.
		#
		# @see http://www.cloudflare.com/docs/client-api.html#s4.7
		#
		# @param ip [String]

		def blacklist(ip)
			send_req({a: :ban, key: ip})
		end

		# This function removes the IP from whitelist or blacklist.
		#
		# @see http://www.cloudflare.com/docs/client-api.html#s4.7
		#
		# @param ip [String]

		def remove_ip(ip)
			send_req({a: :nul, key: ip})
		end

		# This function toggles IPv6 support.
		#
		# @see http://www.cloudflare.com/docs/client-api.html#s4.8
		#
		# @param zone [String]
		# @param value [Boolean] 

		def ipv46(zone, value)
			send_req({a: :ipv46, z: zone, v: value ? 1 : 0})
		end

		# This function changes Rocket Loader setting.
		#
		# @see http://www.cloudflare.com/docs/client-api.html#s4.9
		#
		# @param zone [String]
		# @param value [Integer or String] values: 0|a|m

		def async(zone, value)
			send_req({a: :async, z: zone, v: value})
		end

		# This function changes minification settings.
		#
		# @see http://www.cloudflare.com/docs/client-api.html#s4.10
		#
		# @param zone [String]
		# @param value [Integer] values: 0|2|3|4|5|6|7

		def minify(zone, value)
			send_req({a: :minify, z: zone, v: value})
		end


		# This function changes mirage2 settings.
		#
		# @see http://www.cloudflare.com/docs/client-api.html#s4.11
		#
		# @param zone [String]
		# @param value [Integer] values: 0|1

		def mirage2(zone, value)
			send_req({a: :mirage2, z: zone, v: value})
		end

		# This function creates a new DNS record for your site. This can be either a CNAME or A record.
		#
		# @see http://www.cloudflare.com/docs/client-api.html#s5.1
		#
		# @param zone [String]
		# @param type [String] values: A|CNAME|MX|TXT|SPF|AAAA|NS|SRV|LOC
		# @param name [String]
		# @param content [String]
		# @param ttl [Integer] values: 1|120...4294967295
		# @param prio [Integer] (applies to MX/SRV)
		# @param service [String] (applies to SRV)
		# @param srvname [String] (applies to SRV)
		# @param protocol [Integer] (applies to SRV) values: _tcp|_udp|_tls
		# @param weight [Intger] (applies to SRV)
		# @param port [Integer] (applies to SRV)
		# @param target [String] (applies to SRV)

		def rec_new(zone, type, name, content, ttl, prio = nil, service = nil, srvname = nil, protocol = nil, weight = nil, port = nil, target = nil)
			send_req({
				a: :rec_new,
				z: zone,
				type: type,
				name: name,
				content: content,
				ttl: ttl,
				prio: prio,
				service: service,
				srvname: srvname,
				protocol: protocol,
				weight: weight,
				port: port,
				target: target
			})
		end

		# This function edits a DNS record for a zone.
		#
		# @see http://www.cloudflare.com/docs/client-api.html#s5.2
		#
		# @param zone [String]
		# @param type [String] values: A|CNAME|MX|TXT|SPF|AAAA|NS|SRV|LOC
		# @param record_id [Integer]
		# @param name [String]
		# @param content [String]
		# @param ttl [Integer] values: 1|120...4294967295
		# @param service_mode [Boolean] (applies to A/AAAA/CNAME)
		# @param prio [Integer] (applies to MX/SRV)
		# @param service [String] (applies to SRV)
		# @param srvname [String] (applies to SRV)
		# @param protocol [Integer] (applies to SRV) values: _tcp/_udp/_tls
		# @param weight [Intger] (applies to SRV)
		# @param port [Integer] (applies to SRV)
		# @param target [String] (applies to SRV)

		def rec_edit(zone, type, record_id, name, content, ttl, service_mode = nil, prio = nil, service = nil, srvname = nil, protocol = nil, weight = nil, port = nil, target = nil)
			send_req({
				a: :rec_edit,  
				z: zone,
				type: type,
				id: record_id,
				name: name,
				content: content,
				ttl: ttl,
				service_mode: service_mode ? 1 : 0,
				prio: prio,
				service: service,
				srvname: srvname,
				protocol: protocol,
				weight: weight,
				port: port,
				target: target
			})
		end

		# This functon deletes a record for a domain.
		#
		# @see http://www.cloudflare.com/docs/client-api.html#s5.3
		#
		# @param zone [String]
		# @param zoneid [Integer]

		def rec_delete(zone, zoneid)
			send_req({a: :rec_delete, z: zone, id: zoneid})
		end

		# HOST

		# This function creates a CloudFlare account mapped to your user.
		#
		# @see http://www.cloudflare.com/docs/host-api.html#s3.2.1
		#
		# @param email [String]
		# @param pass [String]
		# @param login [String] (optional) cloudflare_username
		# @param id [Integer] (optional) unique_id
		# @param cui [Integer] (optional) clobber_unique_id

		def create_user(email, pass, login = nil, id = nil, cui = nil)
			send_req({
				act: :user_create,
				cloudflare_email: email,
				cloudflare_pass: pass,
				cloudflare_username: login,
				unique_id: id,
				clobber_unique_id: cui
			})
		end

		# This function setups a User's zone for CNAME hosting.
		#
		# @see http://www.cloudflare.com/docs/host-api.html#s3.2.2
		#
		# @param user_key [String]
		# @param zone [String]
		# @param resolve_to [String]
		# @param subdomains [String or Array]

		def add_zone(user_key, zone, resolve_to, subdomains)
			send_req({
				act: :zone_set,
				user_key: user_key,
				zone_name: zone,
				resolve_to: resolve_to,
				subdomains: subdomains.kind_of?(Array) ? zones.join(',') : subdomains
			})
		end

		# This function lookups a user's CloudFlare account information.
		#
		# @see http://www.cloudflare.com/docs/host-api.html#s3.2.3
		#
		# *Example:*
		#
		#   cf = CloudFlare('your_host_key')
		#   cf.user_lookup('unique_id', true)
		#
		# If +id+ is set to true, email is a unique_id.
		#
		# @param email [String or Integer]
		# @param id [Boolean]

		def user_lookup(email, id = false)
			if id
				send_req({act: :user_lookup, unique_id: email})
			else
				send_req({act: :user_lookup, cloudflare_email: email})
			end
		end

		# This function authorizes access to a user's existing CloudFlare account.
		#
		# @see http://www.cloudflare.com/docs/host-api.html#s3.2.4
		#
		# @param email [String]
		# @param pass [String]
		# @param unique_id [Integer] (optional)
		# @param cui [Integer] (optional) clobber_unique_id

		def user_auth(email, pass, id = nil, cui = nil)
			send_req({
				act: :user_auth,
				cloudflare_email: email,
				cloudflare_pass: pass,
				unique_id: id,
				clobber_unique_id: cui
			})
		end

		# This function lookups a specific user's zone.
		#
		# @see http://www.cloudflare.com/docs/host-api.html#s3.2.5
		#
		# @param user_key [String]
		# @param zone [String]

		def zone_lookup(user_key, zone)
			send_req({act: :zone_lookup, user_key: user_key, zone_name: zone})
		end

		# This function deletes a specific zone on behalf of a user.
		#
		# @see http://www.cloudflare.com/docs/host-api.html#s3.2.6
		#
		# @param user_key [String]
		# @param zone [String]

		def del_zone(user_key, zone)
			send_req({act: :zone_delete, user_key: user_key, zone_name: zone})
		end

		# This function creates a new child host provider.
		#
		# @see http://www.cloudflare.com/docs/host-api.html#s3.2.7
		#
		# @param host_name [String]
		# @param pub_name [String]
		# @param prefix [String]
		# @param website [String]
		# @param email [String]

		def host_child_new(host_name, pub_name, prefix, website, email)
			send_req({
				act: :host_child_new,
				pub_name: pub_name,
				prefix: prefix,
				website: website,
				email: email
			})
		end

		# This function regenerates your host key.
		#
		# @see http://www.cloudflare.com/docs/host-api.html#s3.2.8

		def host_key_regen
			send_req(act: :host_key_regen)
		end

		# This function stops a child host provider account.
		#
		# @see http://www.cloudflare.com/docs/host-api.html#s3.2.9
		#
		# @param id [Integer] child_id

		def host_child_stop(id)
			send_req({act: :host_child_stop, child_id: id})
		end

		# This function lists the domains currently active on CloudFlare for the given host.
		#
		# @see http://www.cloudflare.com/docs/host-api.html#s3.2.10
		#
		# @param limit [Integer] (optional)
		# @param offset [Integer] (optional)
		# @param name [String] (optional) zone_name
		# @param sub_id [Integer] (optional) sub_id
		# @param status [String] (optional) values: V|D|ALL

		def zone_list(limit = 100, offset = 0, name = nil, sub_id = nil, status = nil)
			send_req({
				act: :zone_list,
				offset: offset,
				zone_name: name,
				sub_id: sub_id,
				zone_status: status
			})
		end

		private

		def send_req(params)
			if @params[:email]
				params[:tkn] = @params[:api_key]
				params[:u] = @params[:email]
				uri = URI(URL_API[:client])
			else
				params[:host_key] = @params[:api_key]
				uri = URI(URL_API[:host])
			end

			req = Net::HTTP::Post.new(uri.path)
			req.set_form_data(params)

			http = Net::HTTP.new(uri.host, uri.port)
			http.use_ssl = true
			http.read_timeout = TIMEOUT

			res = http.request(req)
			out = JSON.parse(res.body)

			# If there is an error, raise an exception:
			if out['result'] == 'error'
				raise RequestError.new(out['msg'], out)
			else
				return out
			end
		end
	end
end
