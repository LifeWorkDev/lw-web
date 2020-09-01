class Payments::RecordRefundJob < ApplicationJob
  def perform(payment, refund_amount_cents, refund_id)
    payment.record_refund!(refund_amount_cents, refund_id)
  end
end
