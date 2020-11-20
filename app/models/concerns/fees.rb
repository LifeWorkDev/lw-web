module Fees
  extend ActiveSupport::Concern

  included do
    def client_amount(amount = self.amount)
      amount + client_fees(amount)
    end

    def client_fees(amount = self.amount)
      fees = 0
      fees += platform_fee(amount) if client_pays_fees?
      fees + processing_fee(amount)
    end

    def client_refund_amount(amount = self.amount)
      amount + (client_pays_fees? ? platform_fee(amount) : 0)
    end

    def freelancer_amount(amount = self.amount)
      amount - freelancer_fees(amount)
    end

    def freelancer_fees(amount = self.amount)
      client_pays_fees? ? 0 : platform_fee(amount)
    end

    def platform_fee(amount = self.amount)
      amount * fee_percent
    end

    def processing_fee(amount = self.amount)
      amount * (pay_method&.fee_percent || 0)
    end

    def pay_method
      client.primary_pay_method
    end
  end
end
