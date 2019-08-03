class UsersController < AuthenticatedController
  # PATCH /user
  def update
    @user = current_user
    @user.update(attributes)
    # Don't sign user out after they change their password
    sign_in(@user, bypass: true) if attributes['password'] && @user.valid?
    respond_with(@user)
  end

private

  def attributes
    params.require(:user).permit(:name, :email, :phone, :address, :time_zone, :password)
  end
end
