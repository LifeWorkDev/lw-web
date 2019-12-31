class FreelancerMailerPreview < ActionMailer::Preview
  def deposit_received
    FreelancerMailer.deposit_received(user: User.first, milestone: Milestone.first)
  end

  def milestone_approaching
    FreelancerMailer.milestone_approaching(user: User.first, milestone: Milestone.first)
  end
end
