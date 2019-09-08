class Freelancer::MilestoneProjectsController < MilestoneProjectsController
  # GET /milestone_projects/1/milestones
  def milestones; end

  # GET /milestone_projects/1/payments
  def payments
    @back = [:milestones, current_namespace, @project]
    @heading = 'Tell us how much you should get paid.'
  end

  # PATCH/PUT /milestone_projects/1
  def update
    @project.assign_attributes(milestone_project_params)
    if params[:button].present?
      notice = "#{params[:button].capitalize} were updated." if @project.milestones_changed?
      path = params[:button] == 'payments' ? freelancer_stripe_connect_path : [:payments, current_namespace, @project]
    else
      notice = 'Project was successfully updated.'
      path = [:milestones, current_namespace, @project]
    end
    if @project.save
      redirect_to path, notice: notice
    else
      render params[:button].to_sym
    end
  end
end
