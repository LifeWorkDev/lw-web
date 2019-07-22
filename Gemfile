source 'https://rubygems.org'

ruby "~> #{`cat .ruby-version`.strip}"

gem 'rails', github: 'rails/rails', branch: '6-0-stable'

gem 'argon2' # More secure password hashing than default bcrypt
gem 'devise', github: 'plataformatec/devise', branch: 'master'
gem 'devise_invitable'
gem 'lograge' # one-line logs
gem 'money-rails'
gem 'nilify_blanks', github: 'swrobel/nilify_blanks'
gem 'pg', '>= 0.18', '< 2.0'
gem 'puma', '~> 3.11'
gem 'route_downcaser' # Make routes case-insensitive
gem 'slim-rails' # Template language, lightweight alternative to erb/haml
gem 'strong_migrations' # complains about migration worst-practices
gem 'turbolinks', '~> 5'
gem 'webpacker', github: 'rails/webpacker'

group :development, :test do
  # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  gem 'byebug', platforms: [:mri, :mingw, :x64_mingw]
  gem 'pgreset' # Automatically disconnect active pg clients when dropping database
  gem 'rspec-rails'
  gem 'rubocop', require: false
  gem 'rubocop-rspec', require: false
end

group :development do
  gem 'awesome_print'
  gem 'brakeman' # Security audits
  gem 'bullet' # Notify of N+1s
  gem 'gindex' # rails g index <table> <column(s)>
  gem 'guard'
  gem 'guard-rspec', require: false
  gem 'guard-rubocop', require: false
  gem 'guard-shell', require: false
  gem 'guard-webpack', require: false
  gem 'invoker'
  gem 'listen', '>= 3.0.5', '< 3.2'
  gem 'terminal-notifier'
  gem 'terminal-notifier-guard'
  # Access an interactive console on exception pages or by calling 'console' anywhere in the code.
  gem 'web-console', github: 'rails/web-console'
end

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem 'tzinfo-data', platforms: [:mingw, :mswin, :x64_mingw, :jruby]
