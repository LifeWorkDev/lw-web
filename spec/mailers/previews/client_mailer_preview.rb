class ClientMailerPreview < ActionMailer::Preview
  def invite
    params = { recipient: User.active.sample, project: Project.not_pending.sample }
    params[:reminder] = true if [true, false].sample
    ClientMailer.with(params).invite
  end

  delegate :milestone_approaching, to: :milestone_mailer
  delegate :milestone_deposited, to: :milestone_mailer
  delegate :milestone_paid, to: :milestone_mailer

private

  def milestone_mailer
    ClientMailer.with(milestone_params)
  end

  def milestone_params
    { recipient: User.client.sample, milestone: Milestone.deposited.sample }
  end
end
