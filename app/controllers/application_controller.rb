class ApplicationController < ActionController::Base
  include ::CallbackChain
  include SetLogidzeResponsible

  impersonates :user

  before_action :configure_permitted_parameters, if: :devise_controller?
  before_action :store_user_location!, if: :storable_location?

  protect_from_forgery prepend: true, with: :reset_session

  def privacy; end

  def styleguide; end

  def tos; end

  def after_sign_out_path_for(_resource_or_scope)
    new_user_session_url
  end

  def after_sign_in_path_for(resource)
    stored_location_for(resource) || edit_user_path
  end

protected

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up, keys: [:name])
  end

  def redirect_with_query_string(destination:, status: :moved_permanently)
    redirect_to "#{destination}?#{request.query_string}".chomp('?'), status: status
  end

private

  def storable_location?
    request.get? && is_navigational_format? && !devise_controller? && !request.xhr?
  end

  def store_user_location!
    # :user is the scope we are authenticating
    store_location_for(:user, request.fullpath)
  end

  class Unauthorized < StandardError; end
end
