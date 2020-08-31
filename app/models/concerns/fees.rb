module Fees
  extend ActiveSupport::Concern

  included do
    def client_amount(total = amount)
      total += platform_fee(total) if client_pays_fees?
      total += processing_fee(total)
      total
    end

    def freelancer_amount(total = amount)
      total -= platform_fee(total) unless client_pays_fees?
      total
    end

    def platform_fee(total = amount)
      total * fee_percent
    end

    def processing_fee(total = amount)
      total * (pay_method&.fee_percent || 0)
    end

    def pay_method
      try(:latest_payment)&.pay_method || client.primary_pay_method
    end
  end
end
