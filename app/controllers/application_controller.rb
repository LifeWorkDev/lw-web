class ApplicationController < ActionController::Base
  include ::CallbackChain
  include SetLogidzeResponsible

  impersonates :user

  before_action :configure_permitted_parameters, if: :devise_controller?
  before_action :store_user_location!, if: :storable_location?

  protect_from_forgery prepend: true, with: :reset_session

  def home
    if user_signed_in?
      redirect_to [current_user.type, Project]
    else
      redirect_to '/sign_up'
    end
  end

  def styleguide; end

  def after_sign_out_path_for(_resource_or_scope)
    new_user_session_url
  end

  def after_sign_in_path_for(resource)
    stored_location_for(resource) || [resource.type, Project]
  end

  def after_accept_path_for(resource)
    [:payments, :client, resource.org_projects.first]
  end

  def current_namespace
    self.class.module_parent.to_s.underscore
  end
  helper_method :current_namespace

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
