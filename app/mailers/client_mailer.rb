class ClientMailer < ApplicationMailer
  before_action do
    @for_client = true
    @freelancer_name = (@milestone || @project)&.freelancer&.name
  end

  def invite
    @recipient.invite! unless @recipient.active? # Generate new invitation token

    @get_started_url = @recipient.raw_invitation_token.present? ? accept_user_invitation_url(invitation_token: @recipient.raw_invitation_token) : [:payment, :client, @project]
    make_bootstrap_mail(subject: "#{"[#{t(".reminder")}] " if params[:reminder]}#{t(".subject", freelancer: @project.freelancer.name, project: @project.for_subject)}")
  end

  def milestone_approaching
    make_bootstrap_mail(reply_to: @milestone.comment_reply_address, subject: t(".subject", project: @milestone.project))
  end

  def milestone_deposited
    make_bootstrap_mail(reply_to: @milestone.comment_reply_address, subject: t(".subject", freelancer: @freelancer_name.possessive, project: @milestone.project))
  end

  def milestone_paid
    @next_milestone = @milestone.next
    make_bootstrap_mail(subject: t(".subject", freelancer: @freelancer_name, project: @milestone.project))
  end

  def retainer_deposited
    make_bootstrap_mail(reply_to: @project.comment_reply_address, subject: t(".subject", freelancer: @freelancer_name.possessive, project: @project))
  end

  def retainer_disbursed
    make_bootstrap_mail(subject: t(".subject", freelancer: @freelancer_name, project: @project))
  end
end
