# Copyright, 2012, by Marcin Prokop.
# Copyright, 2017, by Samuel G. D. Williams. <http://www.codeotaku.com>
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

require_relative 'connection'

module Cloudflare
  class Connection < Resource
    def zones
      @zones ||= Zones.new(concat_urls(url, 'zones'), options)
    end
  end
  
  class DNSRecord < Resource
    def initialize(url, record = nil, **options)
      super(url, **options)
      
      @record = record || self.get.result
    end
    
    attr :record
    
    def to_s
      "#{@record[:name]} #{@record[:type]} #{@record[:content]}"
    end
  end
  
  class DNSRecords < Resource
    def initialize(url, zone, **options)
      super(url, **options)
      
      @zone = zone
    end
    
    attr :zone
    
    def all
      self.get.results.map{|record| DNSRecord.new(concat_urls(url, record[:id]), record, **options)}
    end
    
    def find_by_name(name)
      record = self.get(params: {name: name}).result
      
      DNSRecord.new(concat_urls(url, record[:id]), record, **options)
    end
    
    def find_by_id(id)
      DNSRecord.new(concat_urls(url, id), **options)
    end
  end
  
  class Zone < Resource
    def initialize(url, record = nil, **options)
      super(url, **options)
      
      @record = record || self.get.result
    end
    
    attr :record
    
    def dns_records
      @dns_records ||= DNSRecords.new(concat_urls(url, 'dns_records'), self, **options)
    end
    
    def to_s
      @record[:name]
    end
  end
  
  class Zones < Resource
    def all
      self.get.results.map{|record| Zone.new(concat_urls(url, record[:id]), record, **options)}
    end
    
    def find_by_name(name)
      record = self.get(params: {name: name}).result
      
      Zone.new(concat_urls(url, record[:id]), record, **options)
    end
    
    def find_by_id(id)
      Zone.new(concat_urls(url, id), **options)
    end
  end
end
