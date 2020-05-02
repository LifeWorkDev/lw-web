class CommentMailer < ApplicationMailer
  def notify_new_comment
    make_bootstrap_mail(reply_to: @milestone.comment_reply_address,
                        subject: t(".subject", project: @milestone.project.name))
  end
end
