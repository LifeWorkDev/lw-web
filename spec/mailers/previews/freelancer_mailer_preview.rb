class FreelancerMailerPreview < ActionMailer::Preview
  delegate :milestone_approaching, to: :milestone_mailer
  delegate :milestone_deposited, to: :milestone_mailer
  delegate :milestone_paid, to: :milestone_mailer
  delegate :payment_refunded, to: :payment_mailer
  delegate :retainer_agreed, to: :retainer_mailer
  delegate :retainer_deposited, to: :retainer_mailer
  delegate :retainer_disbursed, to: :retainer_mailer

private

  def milestone_mailer
    FreelancerMailer.with({recipient: User.freelancer.sample, milestone: Milestone.deposited.sample})
  end

  def payment_mailer
    payment = Payment.where(status: %i[refunded partially_refunded]).sample
    amount = Money.new(rand(1..payment.amount_cents))
    FreelancerMailer.with({recipient: User.freelancer.sample, payment: payment, refund_amount: amount})
  end

  def retainer_mailer
    FreelancerMailer.with({recipient: User.freelancer.sample, project: RetainerProject.not_pending.sample})
  end
end
