class FreelancerMailerPreview < ActionMailer::Preview
  delegate :milestone_approaching, to: :milestone_mailer
  delegate :milestone_deposited, to: :milestone_mailer
  delegate :milestone_paid, to: :milestone_mailer
  delegate :retainer_agreed, to: :retainer_mailer
  delegate :retainer_deposited, to: :retainer_mailer
  delegate :retainer_disbursed, to: :retainer_mailer

private

  def milestone_mailer
    FreelancerMailer.with(milestone_params)
  end

  def milestone_params
    {recipient: User.freelancer.sample, milestone: Milestone.deposited.sample}
  end

  def retainer_mailer
    FreelancerMailer.with(retainer_params)
  end

  def retainer_params
    {recipient: User.freelancer.sample, project: RetainerProject.not_pending.sample}
  end
end
