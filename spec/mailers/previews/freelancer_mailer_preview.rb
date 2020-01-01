class FreelancerMailerPreview < ActionMailer::Preview
  delegate :milestone_approaching, to: :milestone_mailer

  delegate :milestone_deposited, to: :milestone_mailer

  delegate :milestone_paid, to: :milestone_mailer

private

  def milestone_mailer
    FreelancerMailer.with(milestone_params)
  end

  def milestone_params
    { recipient: User.first, milestone: Milestone.first }
  end
end
