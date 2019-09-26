class Users::ImpersonationsController < AuthenticatedController
  def impersonate
    user = User.find(params[:id])
    raise AuthenticatedController::Forbidden unless true_user.admin?

    impersonate_user(user)
    redirect_to [user.type, Project]
  end

  def stop_impersonating
    stop_impersonating_user
    redirect_back(fallback_location: root_path)
  end
end
