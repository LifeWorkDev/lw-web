class FreelancerMailer < ApplicationMailer
  def milestone_approaching(user:, milestone:)
    Time.use_zone(user.time_zone) do
      @client_name = milestone.client.display_name
      @milestone = milestone
      @user = user
      make_bootstrap_mail(to: user.email, reply_to: milestone.comment_reply_address, subject: t('.subject', project: milestone.project))
    end
  end

  def milestone_deposited(user:, milestone:)
    Time.use_zone(user.time_zone) do
      @milestone = milestone
      make_bootstrap_mail(to: user.email, subject: t('.subject', project: milestone.project))
    end
  end
end
