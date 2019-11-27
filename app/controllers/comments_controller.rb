class CommentsController < AuthenticatedController
  before_action :set_project, only: %i[index create]

  def index
    @milestones = @project.milestones.includes(comments: %i[commenter read_by])
    @project.comments.where.not(commenter: current_user)
            .where(read_at: nil).find_each { |c| c.update(read_by_id: current_user.id, read_at: Time.current) }
  end

  def create
    @comment = current_user.comments.new(comment_params)
    if @comment.save
      CommentMailer.notify_new_comment(user: user_to_notify, milestone: @comment.commentable).deliver_later
      redirect_to [current_namespace, @project, :comments]
    else
      redirect_to [current_namespace, @project, :comments], alert: "Failed to create comment, #{@comment.errors.full_message.join(', ')}"
    end
  end

  def update
    comment = current_user.comments.find(params[:id])
    if comment.update(comment: params[:comment])
      render json: { message: 'Comment successfully updated.' }
    else
      render json: { error: comment.errors.full_messages.join(', ') }, status: 400
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

  def user_to_notify
    @project.freelancer == current_user ? @project.client.primary_contact : @project.freelancer
  end
end
