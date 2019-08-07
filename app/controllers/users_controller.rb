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
    redirect_to new_org_path
  end

private

  def attributes
    params.require(:user).permit(:name, :email, :phone, :address, :time_zone, :password)
  end
end
