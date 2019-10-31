class AuthenticatedController < ApplicationController
  around_action :set_time_zone
  prepend_before_action :authenticate_user!

  def current_org
    current_user.org
  end
  helper_method :current_org

  def current_entity
    current_namespace == 'client' ? current_org : current_user
  end
  helper_method :current_entity

  class Forbidden < StandardError; end

private

  def set_time_zone
    Time.use_zone(current_user&.time_zone) { yield }
  end
end
