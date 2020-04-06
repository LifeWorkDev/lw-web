class Payments::RefundJob < ApplicationJob
  def perform(charge_id)
    Stripe::Refund.create(charge: charge_id)
  end
end
