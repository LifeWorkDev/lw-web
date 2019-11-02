class ClientMailerPreview < ActionMailer::Preview
  def invite
    ClientMailer.invite(user: User.first, project: Project.first)
  end

  def milestone_completed
    ClientMailer.milestone_completed(user: User.first, milestone: Milestone.first)
  end
end
