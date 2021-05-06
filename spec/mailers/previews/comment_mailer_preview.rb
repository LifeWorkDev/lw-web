class CommentMailerPreview < ApplicationMailerPreview
  def notify_new_comment
    @mailer_params = {recipient: comment.recipient, milestone: comment.commentable}
    mailer_with_params.notify_new_comment
  end
end
