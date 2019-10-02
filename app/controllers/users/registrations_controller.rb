class Users::RegistrationsController < Devise::RegistrationsController
  # POST /users
  def create
    super do |resource|
      if resource.errors[:email].first == 'has already been taken'
        set_flash_message! :alert, :existing_user
        redirect_to(new_user_session_path('user[email]': resource.email)) && return
      end
    end
  end

protected

  def after_sign_up_path_for(_resource)
    edit_freelancer_user_path
  end

  def configure_account_update_params
    devise_parameter_sanitizer.permit(:account_update, keys: %i[name])
  end

  # Don't require password re-entry when updating
  def update_resource(resource, params)
    resource.update_without_password(params)
  end
end
