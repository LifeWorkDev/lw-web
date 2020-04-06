module Fees
  extend ActiveSupport::Concern

  included do
    def client_amount(total = amount)
      total += platform_fee if client_pays_fees?
      total += processing_fee
      total
    end

    def freelancer_amount(total = amount)
      total -= platform_fee unless client_pays_fees?
      total
    end

    def platform_fee
      amount * fee_percent
    end

    def processing_fee
      amount * pay_method.fee_percent
    end

    def pay_method
      client.primary_pay_method
    end
  end
end
