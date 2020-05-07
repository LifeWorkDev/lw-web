class FreelancerMailer < ApplicationMailer
  def milestone_approaching
    @client_name = @milestone.client.name
    make_bootstrap_mail(reply_to: @milestone.comment_reply_address, subject: t(".subject", project: @milestone.project))
  end

  def milestone_deposited
    make_bootstrap_mail(reply_to: @milestone.comment_reply_address, subject: t(".subject", project: @milestone.project))
  end

  def milestone_paid
    @next_milestone = @milestone.next
    make_bootstrap_mail(subject: t(".subject", project: @milestone.project))
  end

  def retainer_agreed
    make_bootstrap_mail(reply_to: @project.comment_reply_address, subject: t(".subject", client: @project.client))
  end

  def retainer_deposited
    make_bootstrap_mail(reply_to: @project.comment_reply_address, subject: t(".subject", client: @project.client))
  end
end
