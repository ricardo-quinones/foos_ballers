source 'https://rubygems.org'

gem 'rails', '4.2.1'
gem 'pg'
gem 'jquery-rails'
gem 'turbolinks'
gem 'jbuilder', '~> 2.0'
gem 'haml'
gem 'haml-rails'
# bundle exec rake doc:rails generates the API under doc/api.
gem 'sdoc', '~> 0.4.0', group: :doc
gem 'bootstrap-sass', '~> 3.3.5'
gem 'sass-rails', '~> 5.0'
gem 'bourbon'
gem 'coffee-rails', '~> 4.1.0'
gem 'paperclip'
gem 'factory_girl_rails', :require => false
gem 'rails4-autocomplete', git: 'https://github.com/ricardo-quinones/rails4-autocomplete.git', branch: 'master'
gem 'angular-rails-templates'
gem 'sprockets', '2.12.3'

group :assets do
  # See https://github.com/sstephenson/execjs#readme for more supported runtimes
  # gem 'therubyracer', :platforms => :ruby
  gem 'uglifier', '>= 1.3.0'
end

# Use ActiveModel has_secure_password
gem 'bcrypt', '~> 3.1.7'

group :development do
  gem 'colorize'
  gem 'annotate'
  gem 'better_errors'
  gem 'binding_of_caller', '~> 0.7.2'
end

group :test do
  gem 'vcr'
  gem 'webmock'
end

# Use Unicorn as the app server
# gem 'unicorn'

# Use Capistrano for deployment
# gem 'capistrano-rails', group: :development

group :test, :development do
  gem 'database_cleaner'
  gem 'rspec-rails', '~> 3.3.3'
  gem 'rspec-its'
  gem 'pry'
  gem 'pry-rescue'
  gem 'pry-stack_explorer'
  gem 'pry-byebug'
  gem 'thin'
  gem 'spring'
  gem 'spring-commands-rspec', require: false
end
