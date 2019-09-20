class CommentMailer < ApplicationMailer
  def notify_new_comment(user:, milestone:)
    @user = user
    @milestone = milestone
    make_bootstrap_mail(to: user.email,
                        reply_to: "comments-#{milestone.id}@reply.lifeworkonline.com",
                        subject: t('.subject', project: milestone.project.name))
  end
end
