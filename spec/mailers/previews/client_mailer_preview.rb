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
    params = {recipient: project.freelancer, project: project}
    params[:reminder] = [true, nil].sample
    ClientMailer.with(params).invite
  end

  def milestone_mailer
    ClientMailer.with({recipient: milestone.client.primary_contact, milestone: milestone})
  end

  def payment_mailer
    refund_amount = Money.new(rand(1..payment.amount_cents))
    ClientMailer.with({recipient: payment.client.primary_contact, payment: payment, refund_amount: refund_amount})
  end

  def retainer_mailer
    ClientMailer.with({recipient: retainer_project.client.primary_contact, payment: retainer_payment})
  end
end
