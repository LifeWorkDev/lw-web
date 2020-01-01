class FreelancerMailerPreview < ActionMailer::Preview
  def milestone_approaching
    FreelancerMailer.milestone_approaching(user: User.first, milestone: Milestone.first)
  end

  def milestone_deposited
    FreelancerMailer.milestone_deposited(user: User.first, milestone: Milestone.first)
  end
end
