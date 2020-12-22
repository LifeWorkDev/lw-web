class CommentMailerPreview < ApplicationMailerPreview
  def notify_new_comment
    CommentMailer.with(recipient: comment.recipient, milestone: comment.commentable).notify_new_comment
  end
end
