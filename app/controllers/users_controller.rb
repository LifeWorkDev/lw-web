class UsersController < AuthenticatedController
  def edit; end

  # PATCH /user
  def update
    @user = current_user
    @user.update(attributes)
    if @user.valid?
      @user.after_database_authentication
      # Don't sign user out after they change their password
      bypass_sign_in(@user) if attributes['password'] && @user.valid?
    end
    if params[:org].present? && (org = @user.clients.find(params[:org]))
      redirect_to edit_freelancer_org_path(org)
    else
      redirect_to new_freelancer_org_path
    end
  end

private

  def attributes
    params.require(:user).permit(:name, :email, :phone, :address, :time_zone, :password, :work_type, work_category: [])
  end
end
