# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2014-2024, by Samuel Williams.
# Copyright, 2014, by Marcin Prokop.
# Copyright, 2018, by Leonhardt Wille.

source "https://rubygems.org"

# Specify your gem's dependencies in cloudflare.gemspec
gemspec

group :maintenance, optional: true do
	gem "bake-gem"
	gem "bake-modernize"
	
	gem "utopia-project"
end

group :test do
	gem "sus"
	gem "covered"
	gem "decode"
	gem "rubocop"
	
	gem "sus-fixtures-async"
	
	gem "sinatra"
	gem "webmock"
	
	gem "bake-test"
	gem "bake-test-external"
end
