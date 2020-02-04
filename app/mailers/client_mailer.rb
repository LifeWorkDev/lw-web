class ClientMailer < ApplicationMailer
  before_action { @freelancer_name = @milestone&.freelancer&.name }

  def invite
    @recipient.invite! unless @recipient.active? # Generate new invitation token

    @get_started_url = @recipient.raw_invitation_token.present? ? accept_user_invitation_url(invitation_token: @recipient.raw_invitation_token) : [:payments, :client, @project]
    make_bootstrap_mail(subject: t('.subject', freelancer: @project.freelancer.name))
  end

  def milestone_approaching
    make_bootstrap_mail(reply_to: @milestone.comment_reply_address, subject: t('.subject', project: @milestone.project))
  end

  def milestone_deposited
    make_bootstrap_mail(reply_to: @milestone.comment_reply_address, subject: t('.subject', freelancer: @freelancer_name.possessive, project: @milestone.project))
  end

  def milestone_paid
    @next_milestone = @milestone.next
    make_bootstrap_mail(subject: t('.subject', freelancer: @freelancer_name, project: @milestone.project))
  end
end
