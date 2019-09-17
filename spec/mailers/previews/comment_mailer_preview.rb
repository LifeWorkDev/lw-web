class CommentMailerPreview < ActionMailer::Preview
  def notify_new_comment
    CommentMailer.notify_new_comment(user: User.first, milestone: Milestone.last)
  end
end
