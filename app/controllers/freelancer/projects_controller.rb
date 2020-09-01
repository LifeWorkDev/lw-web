class Freelancer::ProjectsController < ProjectsController
  include Freelancer::ProjectHelpers

  # PATCH/PUT /f/projects/1/invite
  def invite
    notice = "Your client has been emailed an invitation to join the project." if @project.invite_client!
    redirect_to [current_namespace, Project], notice: notice
  end

  def index
    @projects = current_entity.projects.not_archived.order(:name) + current_entity.projects.archived.order(:name)
  end

  # GET /f/projects/1/preview
  def preview
    @for_client = false
    @is_preview = true
  end

  def show
    redirect_to project_path(@project)
  end

  # GET /f/projects/1/status
  def status
    return if request.get?

    @project.update(status: params[:button])
    redirect_to [current_namespace, Project], notice: "We're sorry to hear that. Feel free to reach out and we'll see if we can help!" if @project.proposal_rejected?
    redirect_to next_step(@project), notice: "Congratulations on getting your contract out!" if @project.contract_sent?
  end
end
