class CommentsController < AuthenticatedController
  before_action :set_project, only: %i[index new create]

  def index
    @milestones = @project.milestones.order(:date)
  end

private

  def current_entity
    current_namespace == 'client' ? current_org : current_user
  end

  # Use callbacks to share common setup or constraints between actions.
  def set_project
    @project = current_entity.projects.find(params[:milestone_project_id])
  end

  # Only allow a trusted parameter "white list" through.
  def comment_params
    params.require(:comment).permit(:comment)
  end
end
