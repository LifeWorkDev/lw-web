class Freelancer::UsersController < AuthenticatedController
  def edit; end

  def update
    @user = current_user
    @user.update(attributes)
    @user.after_database_authentication if @user.valid?
    if params[:org].present? && (org = @user.clients.find(params[:org]))
      redirect_to edit_freelancer_org_path(org)
    else
      redirect_to new_freelancer_org_path
    end
  end

private

  def attributes
    params.require(:user).permit(:time_zone, :work_type, work_category: [])
  end
end
