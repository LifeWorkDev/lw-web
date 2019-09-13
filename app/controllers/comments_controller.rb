class CommentsController < AuthenticatedController
  before_action :set_project, only: %i[index new create]

  def index
    @milestones = @project.milestones.includes(comments: %i[commenter read_by])
    @project.comments.where.not(commenter: current_user)
            .where(read_at: nil).find_each { |c| c.update(read_by_id: current_user.id, read_at: Time.current) }
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

  # Use callbacks to share common setup or constraints between actions.
  def set_project
    @project = current_entity.projects.find(params[:milestone_project_id])
  end

  # Only allow a trusted parameter "white list" through.
  def comment_params
    params.require(:comment).permit(:comment, :commentable_id, :commentable_type)
  end
end
