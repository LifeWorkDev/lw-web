module Client
  class MilestoneProjectsController < ProjectsController
    # GET /milestone_projects/1/payments
    def payments
      @back = nil
      @heading = "#{@project.user.name} has initiated the invoicing process with you. To complete the process, please approve the payment schedule and milestones below."
    end

    # PATCH/PUT /milestone_projects/1
    def update
      @project.assign_attributes(project_params)
      notice = "#{params[:button].capitalize} were updated." if @project.milestones_changed?
      if @project.save
        path = params[:button] == 'payments' ? client_projects_path : [:payments, current_namespace, @project]
        redirect_to path, notice: notice
      else
        render params[:button].to_sym
      end
    end
  end
end
