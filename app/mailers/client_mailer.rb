class ClientMailer < ApplicationMailer
  def invite(user:, project:)
    @project = project
    @get_started_url = user.raw_invitation_token.present? ? accept_user_invitation_url(invitation_token: user.raw_invitation_token) : [:payments, :client, project]
    make_bootstrap_mail(to: user.email, subject: t('.subject', user: user.name, project: project.name))
  end
end
