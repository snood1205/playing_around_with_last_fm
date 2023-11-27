# frozen_string_literal: true

source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby File.read '.ruby-version'

gem 'jbuilder'
gem 'pg'
gem 'puma'
gem 'rack-cors'
gem 'rails'
gem 'sass-rails'
gem 'terser'
# Use Redis adapter to run Action Cable in production
# gem 'redis', '~> 4.0'
# Use ActiveModel has_secure_password
gem 'bcrypt'

# Reduces boot times through caching; required in config/boot.rb
gem 'bootsnap', require: false

gem 'bugsnag'
gem 'dotenv-rails'
gem 'kaminari'
gem 'pry-rails'
gem 'sidekiq'
gem 'simple_form'

group :development, :test do
  gem 'byebug', platforms: %i[mri mingw x64_mingw]
  gem 'factory_bot_rails'
  gem 'faker'
  gem 'rspec_junit_formatter'
  gem 'rspec-rails'
end

group :development do
  gem 'capistrano-rails'
  gem 'foreman'
  gem 'listen'
  gem 'rubocop-capybara'
  gem 'rubocop-factory_bot'
  gem 'rubocop-rails'
  gem 'rubocop-rspec'
  gem 'spring'
  gem 'spring-watcher-listen'
  gem 'web-console'
  gem 'yard'
end

group :test do
  gem 'capybara'
  gem 'shoulda-matchers'
  gem 'simplecov', require: false
end

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem 'tzinfo-data', platforms: %i[mingw mswin x64_mingw jruby]

