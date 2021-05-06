class FreelancerMailerPreview < ApplicationMailerPreview
  delegate :milestone_approaching, to: :milestone_mailer
  delegate :milestone_deposited, to: :milestone_mailer
  delegate :milestone_paid, to: :milestone_mailer
  delegate :payment_refunded, to: :payment_mailer
  delegate :retainer_agreed, to: :retainer_mailer
  delegate :retainer_deposited, to: :retainer_mailer
  delegate :retainer_disbursed, to: :retainer_mailer

private

  def milestone_mailer
    @mailer_params = {recipient: milestone.freelancer, milestone: milestone}
    mailer_with_params
  end

  def payment_mailer
    refund_amount = Money.new(rand(1..payment.amount_cents))
    @mailer_params = {recipient: payment.freelancer, payment: payment, refund_amount: refund_amount}
    mailer_with_params
  end

  def retainer_mailer
    @mailer_params = {recipient: retainer_project.freelancer, payment: retainer_payment}
    mailer_with_params
  end
end
