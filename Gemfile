# frozen_string_literal: true

source 'https://rubygems.org'

gem 'rails', '~> 5.2.0'

gem 'pg'
gem 'groupdate'
gem 'hairtrigger', git: 'https://github.com/liaden/hair_trigger'
gem 'activerecord-import'

gem 'puma'

gem 'bootsnap'

gem 'jquery-rails'
gem 'font-awesome-rails'
gem 'momentjs-rails'
gem 'bootstrap', '~> 4.3'
gem 'autoprefixer-rails', '~> 9.1'
# using my fork because setting format through javascript isn't working nicely atm
gem 'bootstrap4-datetime-picker-rails', git: 'https://github.com/liaden/bootstrap4-datetime-picker-rails'

gem 'haml'
gem 'gon'
gem 'simple_form'
gem 'sprockets', '~> 3.6'
gem 'uglifier'
gem 'mini_racer'

# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem 'jbuilder', '~> 2.0'
gem 'json', '~> 2.0'
# bundle exec rake doc:rails generates the API under doc/api.
# gem 'sdoc', '~> 0.4.0', group: :doc

# Use ActiveModel has_secure_password
# gem 'bcrypt', '~> 3.1.7'

gem 'mutations'
gem 'virtus'

gem 'novus-nvd3-rails'
gem 'chartkick'

gem 'money-rails'

group :development, :test do
  gem 'byebug'
  gem 'rspec-rails'
  gem 'pry'
  gem 'pry-nav'
  gem 'pry-rescue'
  gem 'factory_bot_rails'
  gem 'rubocop'
  gem 'rubocop-performance'
end

group :test do
  gem 'shoulda', '~> 3.5.0'
  # gem 'shoulda-matchers', github: 'thoughtbot/shoulda-matchers'
  gem 'rails-controller-testing'
  gem 'simplecov', require: false
  gem 'faker'
  gem 'database_cleaner'
end

group :development do
  gem 'brakeman', require: false
  # Access an IRB console on exception pages or by using <%= console %> in views
  gem 'web-console', '~> 2.0'

  gem 'listen'

  # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
  gem 'spring'

  gem 'rails-erd'
end
