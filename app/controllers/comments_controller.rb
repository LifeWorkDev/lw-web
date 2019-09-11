class CommentsController < AuthenticatedController
  before_action :set_project, only: %i[index new create]

  def index
    @milestones = @project.milestones.order(:date)
  end

  def create
    @comment = current_user.comments.new(comment_params)
    if @comment.save
      redirect_to [current_namespace, @project, :comments], notice: 'Comment was successfully created.'
    else
      redirect_to [current_namespace, @project, :comments], alert: "Failed to create comment, #{@comment.errors.full_message.join(', ')}"
    end
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
    params.require(:comment).permit(:comment, :commentable_id, :commentable_type)
  end
end
