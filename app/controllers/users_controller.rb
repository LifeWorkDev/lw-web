class UsersController < AuthenticatedController
  def edit; end

  # PATCH /user
  def update
    @user = current_user
    @user.update(attributes)
    # Don't sign user out after they change their password
    sign_in(@user, bypass: true) if attributes['password'] && @user.valid?
    redirect_to new_organization_path
  end

private

  def attributes
    params.require(:user).permit(:name, :email, :phone, :address, :time_zone, :password)
  end
end
