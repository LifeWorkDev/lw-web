class Users::InvitationsController < Devise::InvitationsController
  before_action :permitted_update_parameters, only: :update

protected

  def permitted_update_parameters
    devise_parameter_sanitizer.permit(:accept_invitation, keys: %i[name email time_zone])
  end
end
