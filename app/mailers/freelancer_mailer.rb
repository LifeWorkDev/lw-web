class FreelancerMailer < ApplicationMailer
  def milestone_approaching
    @client_name = @milestone.client.display_name
    make_bootstrap_mail(reply_to: @milestone.comment_reply_address, subject: t('.subject', project: @milestone.project))
  end

  def milestone_deposited
    make_bootstrap_mail(subject: t('.subject', project: @milestone.project))
  end

  def milestone_paid
    make_bootstrap_mail(subject: t('.subject', project: @milestone.project))
  end
end
