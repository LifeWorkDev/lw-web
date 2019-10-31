NOTIFY_RELEASE_STAGES = %w[production staging].freeze

Bugsnag.configure do |config|
  config.api_key = '71c984e7c30babb231447b66654b4a49'
  config.notify_release_stages = NOTIFY_RELEASE_STAGES
  config.send_environment = true
  config.app_version = ENV['HEROKU_RELEASE_VERSION']
  config.ignore_classes << ActiveRecord::RecordNotFound
  config.ignore_classes << AuthenticatedController::Forbidden
  config.ignore_classes << ApplicationController::Unauthorized
  config.ignore_classes << Stripe::CardError
end
