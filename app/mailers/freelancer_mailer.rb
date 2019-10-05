class FreelancerMailer < ApplicationMailer
  def deposit_received(user:, project:, amount:)
    Time.use_zone(user.time_zone) do
      @amount = amount
      make_bootstrap_mail(to: user.email, subject: t('.subject', project: project.name))
    end
  end
end
