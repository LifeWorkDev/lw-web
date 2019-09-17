class CommentMailer < ApplicationMailer
  def notify_new_comment(user:, milestone:)
    @user = user
    @milestone = milestone
    make_bootstrap_mail(to: user.email,
                        reply_to: "#{user.id}+#{milestone.id}@reply.lifework.com",
                        subject: t('.subject', milestone: milestone.description))
  end
end
