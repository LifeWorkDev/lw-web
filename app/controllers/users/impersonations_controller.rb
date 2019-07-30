class Users::ImpersonationsController < AuthenticatedController
  def impersonate
    user = User.find(params[:id])
    # raise SecurityError unless Ability.new(true_user).can? :impersonate, user
    impersonate_user(user)
    # redirect_to dashboard_path
  end

  def stop_impersonating
    stop_impersonating_user
    # redirect_back(fallback_location: admin_path)
  end
end
