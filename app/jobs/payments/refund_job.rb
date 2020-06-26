class Payments::RefundJob < ApplicationJob
  def perform(payment)
    payment.refund!
  end
end
