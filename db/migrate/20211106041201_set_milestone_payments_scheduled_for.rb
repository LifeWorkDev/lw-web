class SetMilestonePaymentsScheduledFor < ActiveRecord::Migration[6.1]
  def up
    Payment.milestone.where(scheduled_for: nil).includes(:pays_for).each do |payment|
      payment.update(scheduled_for: payment.pays_for.date)
    end
  end
end
