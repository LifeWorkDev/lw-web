class ClientMailerPreview < ActionMailer::Preview
  def invite
    params = {recipient: User.active.sample, project: Project.not_pending.sample}
    params[:reminder] = true if [true, false].sample
    ClientMailer.with(params).invite
  end

  delegate :milestone_approaching, to: :milestone_mailer
  delegate :milestone_deposited, to: :milestone_mailer
  delegate :milestone_paid, to: :milestone_mailer
  delegate :retainer_deposited, to: :retainer_mailer

private

  def milestone_mailer
    ClientMailer.with(milestone_params)
  end

  def milestone_params
    {recipient: User.client.sample, milestone: Milestone.deposited.sample}
  end

  def retainer_mailer
    ClientMailer.with(retainer_params)
  end

  def retainer_params
    {recipient: User.client.sample, project: RetainerProject.not_pending.sample}
  end
end
