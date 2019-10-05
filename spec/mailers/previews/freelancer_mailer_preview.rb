class FreelancerMailerPreview < ActionMailer::Preview
  def deposit_received
    FreelancerMailer.deposit_received(user: User.first, project: Project.first, amount: Milestone.first.amount)
  end
end
