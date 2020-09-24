class Payments::RecordRefundJob < ApplicationJob
  def perform(**args)
    payment = args.delete(:payment)
    payment.record_refund!(**args)
  end
end
