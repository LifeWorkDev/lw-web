class Freelancer::MilestoneProjectsController < MilestoneProjectsController
  include Freelancer::ProjectPath

  # GET /f/milestone_projects/1/milestones
  def milestones; end

  # GET /f/milestone_projects/1/payment
  def payment
    @back = [:milestones, current_namespace, @project]
    @heading = "Tell us how much you should get paid."
  end

  # PATCH/PUT /f/milestone_projects/1
  def update
    @project.assign_attributes(milestone_project_params)
    path = if params[:button].present?
             params[:button] == "milestones" ? [:payment, current_namespace, @project] : [:preview, current_namespace, @project.becomes(Project)]
           else
             next_step(@project)
           end
    if @project.save
      redirect_to path
    else
      render params[:button].to_sym
    end
  end
end
