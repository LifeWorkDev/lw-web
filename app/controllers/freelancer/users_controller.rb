class Freelancer::UsersController < AuthenticatedController
  def edit
  end

  def update
    @user = current_user
    @user.update(attributes)
    @user.after_database_authentication if @user.valid?
    if !@user.in_north_america?
      redirect_to waitlist_freelancer_user_path
    elsif params[:client].present? && (org = @user.clients.find(params[:client]))
      redirect_to edit_freelancer_org_path(org)
    else
      redirect_to freelancer_content_walkthrough_path
    end
  end

  def waitlist
  end

private

  def attributes
    params.require(:user).permit(:time_zone, :how_did_you_hear_about_us, :work_type, work_category: [])
  end
end
