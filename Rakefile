# frozen_string_literal: true

require 'bundler/gem_tasks'
require 'rspec/core/rake_task'

RSpec::Core::RakeTask.new(:test)

task default: :test

task :coverage do
	ENV['COVERAGE'] = 'y'
end

task :console do
	require_relative 'lib/cloudflare'
	require 'pry'

	email = ENV.fetch('CLOUDFLARE_EMAIL')
	key = ENV.fetch('CLOUDFLARE_KEY')

	Async.run do
		connection = Cloudflare.connect(key: key, email: email)
		
		binding.pry
	end
end
