# frozen_string_literal: true

source 'https://rubygems.org'

# Specify your gem's dependencies in cloudflare.gemspec
gemspec

gem 'async-http', '~> 0.48', '>= 0.48.2'

group :maintenance, optional: true do
	gem "bake-bundler"
	gem "bake-modernize"
	
	gem "utopia-project"
end

group :test do
	gem 'coveralls', require: false
	gem 'simplecov'
	gem 'sinatra'
	gem 'webmock'
	gem 'dotenv'
end
