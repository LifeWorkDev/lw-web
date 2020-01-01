class CommentMailerPreview < ActionMailer::Preview
  def notify_new_comment
    CommentMailer.with(recipient: User.first, milestone: Comment.last.commentable).notify_new_comment
  end
end
