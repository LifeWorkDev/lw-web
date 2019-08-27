module Freelancer
  class MilestoneProjectsController < ProjectsController
    # GET /milestone_projects/1/milestones
    def milestones; end

    # GET /milestone_projects/1/payments
    def payments; end

    # PATCH/PUT /milestone_projects/1
    def update
      @project.assign_attributes(project_params)
      notice = "#{params[:button].capitalize} were updated." if @project.milestones_changed?
      if @project.save
        path = params[:button] == 'payments' ? freelancer_stripe_connect_path : [:payments, :freelancer, @project]
        redirect_to path, notice: notice
      else
        render params[:button].to_sym
      end
    end
  end
end
