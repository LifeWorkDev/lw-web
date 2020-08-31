class Payments::RecordRefundJob < ApplicationJob
  def perform(payment, refund_amount, refund_id)
    payment.record_refund!(refund_amount, refund_id)
  end
end
