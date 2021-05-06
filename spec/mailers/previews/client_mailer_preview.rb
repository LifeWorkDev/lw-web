class ClientMailerPreview < ApplicationMailerPreview
  def milestone_invite
    invite(milestone_project)
  end

  def retainer_invite
    invite(retainer_project)
  end

  delegate :milestone_approaching, to: :milestone_mailer
  delegate :milestone_deposited, to: :milestone_mailer
  delegate :milestone_paid, to: :milestone_mailer
  delegate :payment_refunded, to: :payment_mailer
  delegate :retainer_deposited, to: :retainer_mailer
  delegate :retainer_disbursed, to: :retainer_mailer

private

  def invite(project)
    @mailer_params = {recipient: project.client.primary_contact, project: project, reminder: [true, nil].sample}
    mailer_with_params.invite
  end

  def milestone_mailer
    @mailer_params = {recipient: milestone.client.primary_contact, milestone: milestone}
    mailer_with_params
  end

  def payment_mailer
    refund_amount = Money.new(rand(1..payment.amount_cents))
    @mailer_params = {recipient: payment.client.primary_contact, payment: payment, refund_amount: refund_amount}
    mailer_with_params
  end

  def retainer_mailer
    @mailer_params = {recipient: retainer_project.client.primary_contact, payment: retainer_payment}
    mailer_with_params
  end
end
