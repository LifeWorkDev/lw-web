class ApplicationController < ActionController::Base
  include ::CallbackChain

  impersonates :user

  before_action :configure_permitted_parameters, if: :devise_controller?
  before_action :store_user_location!, if: :storable_location?

  protect_from_forgery prepend: true, with: :reset_session

  def home
    if user_signed_in?
      redirect_to user_default_path
    else
      redirect_to '/sign_up'
    end
  end

  def styleguide; end

  def after_sign_out_path_for(_resource_or_scope)
    new_user_session_url
  end

  def after_sign_in_path_for(resource)
    stored_location_for(resource) || user_default_path
  end

  def after_accept_path_for(_resource)
    edit_client_org_path
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

  def next_step(project)
    if project.may_invite_client?
      [:milestones, current_namespace, project]
    else
      [:status, current_namespace, project.becomes(Project)]
    end
  end

  def storable_location?
    request.get? && is_navigational_format? && !devise_controller? && !request.xhr?
  end

  def store_user_location!
    # :user is the scope we are authenticating
    store_location_for(:user, request.fullpath)
  end

  def user_default_path
    if current_user.time_zone.present?
      [current_user.type, Project]
    elsif current_user.freelancer?
      edit_freelancer_user_path
    else
      edit_user_path
    end
  end

  class Unauthorized < StandardError; end
end
