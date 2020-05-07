class UsersController < AuthenticatedController
  def edit
  end

  # PATCH /user
  def update
    @user = current_user
    @user.update(attributes)
    if @user.valid?
      # Don't sign user out after they change their password
      bypass_sign_in(@user) if attributes["password"] && @user.valid?
      redirect_to edit_user_path, notice: "Your profile was successfully updated."
    else
      render :edit
    end
  end

private

  def attributes
    params.require(:user)
      .permit(:name, :email, :phone, :address, :time_zone, :password, :email_opt_in)
      .delete_if { |key, value| key == "password" && value.blank? }
  end
end
