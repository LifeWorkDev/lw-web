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
    FreelancerMailer.with({recipient: milestone.freelancer, milestone: milestone})
  end

  def payment_mailer
    refund_amount = Money.new(rand(1..payment.amount_cents))
    FreelancerMailer.with({recipient: payment.freelancer, payment: payment, refund_amount: refund_amount})
  end

  def retainer_mailer
    FreelancerMailer.with({recipient: retainer_project.freelancer, project: retainer_project})
  end
end
