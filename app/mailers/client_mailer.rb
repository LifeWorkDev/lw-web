class ClientMailer < ApplicationMailer
  def invite(user:, project:)
    user.invite! unless user.active? # Generate new invitation token

    Time.use_zone(user.time_zone) do
      @project = project
      @get_started_url = user.raw_invitation_token.present? ? accept_user_invitation_url(invitation_token: user.raw_invitation_token) : [:payments, :client, project]
      make_bootstrap_mail(to: user.email, subject: t('.subject', user: project.freelancer.name, project: project.name))
    end
  end
end
