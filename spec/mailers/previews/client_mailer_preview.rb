class ClientMailerPreview < ActionMailer::Preview
  def invite
    ClientMailer.with(recipient: User.first, project: Project.first).invite
  end

  delegate :milestone_approaching, to: :milestone_mailer

  delegate :milestone_paid, to: :milestone_mailer

private

  def milestone_mailer
    ClientMailer.with(milestone_params)
  end

  def milestone_params
    { recipient: User.first, milestone: Milestone.first }
  end
end
