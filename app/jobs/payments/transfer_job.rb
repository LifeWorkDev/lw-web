class Payments::RefundJob < ApplicationJob
  def perform(payment)
    payment.transfer!
  end
end
