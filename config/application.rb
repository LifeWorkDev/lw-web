require_relative 'boot'

require 'rails'
# Pick the frameworks you want:
require 'active_model/railtie'
require 'active_job/railtie'
require 'active_record/railtie'
require 'active_storage/engine'
require 'action_controller/railtie'
require 'action_mailer/railtie'
require 'action_mailbox/engine'
require 'action_text/engine'
require 'action_view/railtie'
require 'action_cable/engine'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module LifeWork
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 6.0

    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration can go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded after loading
    # the framework and any gems in your application.

    # Disable Rails 5.2 default forgery protection, which is by default by the
    # :exception method, rather than :reset_session, which is what we want
    config.action_controller.default_protect_from_forgery = false

    config.action_dispatch.rescue_responses.merge!(
      'AuthenticatedController::Forbidden' => :forbidden,
      'ApplicationController::Unauthorized' => :unauthorized,
    )

    config.active_record.schema_format = :sql

    config.active_job.queue_adapter = :que
    config.action_mailer.deliver_later_queue_name = 'default'

    config.generators do |g|
      g.helper          false
      g.stylesheets     false
      g.javascripts     false
      g.resource_route  false
      g.serializer      false
      g.system_tests    false
      g.template_engine false
      g.test_framework  :rspec,
                        controller_specs: false,
                        request_specs: false,
                        routing_specs: false,
                        view_specs: false
    end

    config.lograge.enabled = true
    config.lograge.custom_payload do |controller|
      payload = {}
      user = controller.current_user.try(:id)
      payload[:user] = user if user.present?
      payload
    end
    config.lograge.custom_options = lambda do |event|
      exceptions = %w[_method action authenticity_token base code commit controller format id mode path utf8]
      params = event.payload[:params].except(*exceptions)
      # gsub is to use less-verbose new hash syntax
      params.present? ? { params: params.deep_symbolize_keys.to_s.gsub(/(:(\w+)\s?=>\s?)/, '\\2: ') } : nil
    end

    host = ENV['DOMAIN'].presence
    host ||= "#{ENV['SUBDOMAIN']}.lifeworkonline.com" if ENV['SUBDOMAIN']
    host ||= "#{ENV['HEROKU_APP_NAME']}.herokuapp.com" if ENV['HEROKU_APP_NAME']
    host ||= 'lifework.localhost'
    server_url = "https://#{host}"

    unless Rails.env.test?
      config.action_mailer.asset_host = server_url
      config.hosts << host
      Rails.application.routes.default_url_options = { host: server_url, protocol: 'https' }
    end
  end
end

REPLIES_HOST ||= "#{ENV['SUBDOMAIN']}-reply.lifeworkonline.com".freeze
WORK_CATEGORIES = ['Accounting & Consulting', 'Admin Support', 'Customer Service', 'Data Science & Analytics', 'Design & Creative', 'Engineering & Architecture', 'IT & Networking', 'Legal', 'Sales & Marketing', 'Translation', 'Web, Mobile & Software Dev', 'Writing'].freeze
