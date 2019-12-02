class Freelancer::UsersController < AuthenticatedController
  def edit; end

  def update
    @user = current_user
    @user.update(attributes)
    @user.after_database_authentication if @user.valid?
    if !@user.in_north_america?
      redirect_to waitlist_freelancer_user_path
    elsif params[:org].present? && (org = @user.clients.find(params[:org]))
      redirect_to edit_freelancer_org_path(org)
    elsif @user.stripe_id.present?
      redirect_to new_freelancer_org_path
    else
      redirect_to freelancer_stripe_connect_path
    end
  end

  def waitlist; end

private

  def attributes
    params.require(:user).permit(:time_zone, :work_type, work_category: [])
  end
end
