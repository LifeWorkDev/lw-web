class Mailers::ClientReminderJob < ApplicationJob
  def perform(project)
    return unless project.client_invited?

    ClientMailer.with(recipient: project.client.primary_contact, project: project, reminder: true).invite.deliver_now
  end
end
