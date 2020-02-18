class Client::MilestoneProjectsController < MilestoneProjectsController
  # GET /milestone_projects/1/payment
  def payment
    @heading = "#{@project.freelancer.name} has initiated the invoicing process with you. To complete the process, please approve the payment schedule and milestones below."
  end

  # PATCH/PUT /milestone_projects/1
  def update
    @project.assign_attributes(milestone_project_params)
    notice = "#{params[:button].capitalize} were updated." if @project.milestones_changed?
    if @project.save
      redirect_to [:deposit, :client, @project.becomes(Project)], notice: notice
    else
      render params[:button].to_sym
    end
  end
end
