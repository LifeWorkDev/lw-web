class Client::MilestoneProjectsController < MilestoneProjectsController
  def deposit
    return unless request.post?

    milestone = @project.milestones.first
    milestone.deposit!
    redirect_to [current_namespace, Project], notice: "Your deposit was received. #{@project.freelancer.name} has been notified so they can start work on your project."
  end

  # GET /milestone_projects/1/payments
  def payments
    @heading = "#{@project.freelancer.name} has initiated the invoicing process with you. To complete the process, please approve the payment schedule and milestones below."
  end

  # PATCH/PUT /milestone_projects/1
  def update
    @project.assign_attributes(milestone_project_params)
    notice = "#{params[:button].capitalize} were updated." if @project.milestones_changed?
    if @project.save
      if current_org.primary_pay_method
        redirect_to [:deposit, :client, @project], notice: notice
      else
        redirect_to "/c/pay_methods?project=#{@project.slug}", notice: notice
      end
    else
      render params[:button].to_sym
    end
  end
end
