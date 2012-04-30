Gem::Specification.new do |s|
  s.name        = 'cloudflare'
  s.version     = '1.0.0'
  s.date        = '2012-05-30'

  s.description = "A Ruby wrapper for the CloudFlare API."
  s.summary     = "A Ruby wrapper for the CloudFlare API."
  s.authors     = ["Marcin 'B4k3r' Prokop"]
  s.email       = 'marcin@prokop.co'
  s.homepage    = 'http://b4k3r.github.com/cloudflare/'

  s.files            = ['Rakefile', 'lib/cloudflare.rb', 'test/test_cloudflare.rb', 'README.md', 'LICENSE']
  s.test_files       = ['test/test_cloudflare.rb']
  s.rdoc_options     = ['--main', 'README.md', '--charset=UTF-8']
  s.extra_rdoc_files = ['README.md', 'LICENSE']

  s.required_ruby_version = '>= 1.9.0'
  s.add_runtime_dependency('json')
end
