require "bundler/gem_tasks"
require 'rake/testtask'

Rake::TestTask.new do |t|
  t.libs << 'test'
end

desc "Run tests"
task :default => :test

task :console do
  require 'cloudflare'
  require 'pry'
  
  email = ENV['CLOUDFLARE_EMAIL']
  key = ENV['CLOUDFLARE_KEY']
  
  connection = Cloudflare::Connection.new(key: key, email: email)
  
  binding.pry
end
