class AuthenticatedController < ApplicationController
  before_action :set_raven_context if defined?(Raven)
  prepend_before_action :authenticate_user!

  def current_org
    current_user.org
  end
  helper_method :current_org

  class Forbidden < StandardError; end

private

  def set_raven_context
    Raven.user_context(
      id: current_user.id,
      email: current_user.email,
      username: current_user.name,
      ip_address: request.ip,
    )
  end
end
