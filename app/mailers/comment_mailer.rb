class CommentMailer < ApplicationMailer
  def notify_new_comment(user:, milestone:)
    Time.use_zone(user.time_zone) do
      @user = user
      @milestone = milestone
      make_bootstrap_mail(to: user.email,
                          reply_to: milestone.comment_reply_address,
                          subject: t('.subject', project: milestone.project.name))
    end
  end
end
