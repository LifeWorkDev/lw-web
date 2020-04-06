class Payments::TransferJob < ApplicationJob
  def perform(payment)
    payment.transfer!
  end
end
