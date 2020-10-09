source "https://rubygems.org"

group :development do
  gem "overcommit" # Git commit hooks
  gem "rubocop-daemon", require: false # Run rubocop as a daemon so it starts up faster
end

group :development, :test do
  gem "rubocop", require: false
  gem "rubocop-performance", require: false
  gem "rubocop-rails", require: false
  gem "rubocop-rspec", require: false
  gem "slim_lint", require: false
  gem "standard", ">= 0.3", require: false
end
