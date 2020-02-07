class CommentMailerPreview < ActionMailer::Preview
  def notify_new_comment
    comment = Comment.sample
    CommentMailer.with(recipient: comment.recipient, milestone: comment.commentable).notify_new_comment
  end
end
