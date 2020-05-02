require File.expand_path("production.rb", __dir__)

Rails.application.configure do # overrides
  # Enable mailer previews
  config.action_mailer.logger = ActiveSupport::Logger.new(STDOUT) if ENV["RAILS_LOG_TO_STDOUT"].present?
  config.action_mailer.show_previews = true
  config.action_mailer.preview_path = "#{::Rails.root}/spec/mailers/previews"
  ActiveSupport::Dependencies.autoload_paths << config.action_mailer.preview_path
end
