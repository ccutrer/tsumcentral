source 'https://rubygems.org'


gem 'bcrypt', '~> 3.1'
gem 'rails', '~> 7.0'
gem 'rails-i18n', '~> 7.0'
gem 'sprockets-rails', '~> 3.4'
gem 'sqlite3'
gem 'puma', '~> 5.6'

# Use Capistrano for deployment
# gem 'capistrano-rails', group: :development

group :development, :test do
  gem 'byebug', platforms: [:mri, :mingw, :x64_mingw]
end

group :development do
  gem 'capistrano-rails', '~> 1.3.1'
  # Access an IRB console on exception pages or by using <%= console %> anywhere in the code.
  gem 'web-console', '~> 4.2'
  gem 'spring'
end

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem 'tzinfo-data', platforms: [:mingw, :mswin, :x64_mingw, :jruby]
