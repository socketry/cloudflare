# frozen_string_literal: true

require 'bundler/gem_tasks'
require 'rspec/core/rake_task'

RSpec::Core::RakeTask.new(:test)

task default: :test

task :coverage do
	ENV['COVERAGE'] = 'y'
end

task :console do
	require 'cloudflare'
	require 'pry'

	email = ENV['CLOUDFLARE_EMAIL']
	key = ENV['CLOUDFLARE_KEY']

	connection = Cloudflare::Connection.new(key: key, email: email)

	binding.pry
end
