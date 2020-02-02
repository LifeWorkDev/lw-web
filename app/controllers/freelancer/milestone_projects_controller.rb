class Freelancer::MilestoneProjectsController < MilestoneProjectsController
  include Freelancer::ProjectPath

  # PATCH/PUT /f/milestone_projects/1/activate
  def activate
    notice = 'Your client has been emailed an invitation to join the project.' if @project.invite_client!
    redirect_to [current_namespace, Project], notice: notice
  end

  # GET /f/milestone_projects/1/milestones
  def milestones; end

  # GET /f/milestone_projects/1/payments
  def payments
    @back = [:milestones, current_namespace, @project]
    @heading = 'Tell us how much you should get paid.'
  end

  # GET /f/milestone_projects/1/preview
  def preview
    @back = [:payments, current_namespace, @project]
    @hide_email_footer = true
  end

  def show
    redirect_to project_path(@project)
  end

  # PATCH/PUT /f/milestone_projects/1
  def update
    @project.assign_attributes(milestone_project_params)
    if params[:button].present?
      view = params[:button] == 'payments' ? :preview : :payments
      path = [view, current_namespace, @project]
    else
      path = next_step(@project)
    end
    if @project.save
      redirect_to path
    else
      render params[:button].to_sym
    end
  end
end
