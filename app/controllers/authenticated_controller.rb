class AuthenticatedController < ApplicationController
  prepend_before_action :authenticate_user!

  def current_org
    current_user.org
  end
  helper_method :current_org

  class Forbidden < StandardError; end
end
