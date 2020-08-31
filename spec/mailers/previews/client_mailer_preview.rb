class ClientMailerPreview < ActionMailer::Preview
  def milestone_invite
    invite(MilestoneProject.not_pending.sample)
  end

  def retainer_invite
    invite(random_retainer_project)
  end

  delegate :milestone_approaching, to: :milestone_mailer
  delegate :milestone_deposited, to: :milestone_mailer
  delegate :milestone_paid, to: :milestone_mailer
  delegate :payment_refunded, to: :payment_mailer
  delegate :retainer_deposited, to: :retainer_mailer
  delegate :retainer_disbursed, to: :retainer_mailer

private

  def invite(project)
    params = {recipient: User.active.sample, project: project}
    params[:reminder] = true if [true, false].sample
    ClientMailer.with(params).invite
  end

  def milestone_mailer
    ClientMailer.with({recipient: User.client.sample, milestone: Milestone.deposited.sample})
  end

  def payment_mailer
    payment = Payment.where(status: %i[refunded partially_refunded]).sample
    amount = Money.new(rand(1..payment.amount_cents))
    ClientMailer.with({recipient: User.client.sample, payment: payment, refund_amount: amount})
  end

  def random_retainer_project
    RetainerProject.not_pending.sample
  end

  def retainer_mailer
    ClientMailer.with({recipient: User.client.sample, project: random_retainer_project})
  end
end
