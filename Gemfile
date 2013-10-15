source 'https://rubygems.org'
ruby '2.0.0'
gem 'rails', '4.0.0'
gem 'sass-rails', '~> 4.0.0'
gem 'uglifier', '>= 1.3.0'
gem 'coffee-rails', '~> 4.0.0'
gem 'jquery-rails'
gem 'turbolinks'
gem 'jbuilder', '~> 1.2'
gem 'bootstrap-sass', '~> 2.3.2.2'
gem 'font-awesome-rails'
gem 'devise'
gem 'figaro'
gem 'net-ssh'
gem 'net-scp'
gem 'pg'
gem 'simple_form', '>= 3.0.0.rc'
gem 'aws-sdk', github: 'aws/aws-sdk-ruby'
gem 'cocoon'
gem 'show_for', github: 'plataformatec/show_for'
group :development do
  gem 'better_errors'
  #noinspection RailsParamDefResolve
  gem 'binding_of_caller', platforms: [:mri_19, :mri_20, :rbx]
  gem 'meta_request'
  gem 'coffee-rails-source-maps'
  gem 'guard-bundler'
  gem 'guard-rails'
  gem 'guard-rspec', require: false, github: 'guard/guard-rspec'
  gem 'guard-livereload', require: false
  gem 'hub', require: nil
  gem 'quiet_assets'
  gem 'rails_layout'
  gem 'rb-fchange', require: false
  gem 'rb-fsevent', require: false
  gem 'rb-inotify', require: false
end
group :development, :test do
  gem 'factory_girl_rails'
  gem 'rspec-rails'
end
group :production do
  #gem 'unicorn'
  gem 'passenger'
end
group :test do
  gem 'capybara'
  gem 'database_cleaner' #, '1.0.1'
  gem 'email_spec'
  gem 'codeclimate-test-reporter', require: nil
  gem 'coveralls', require: false
  gem 'launchy'
end
