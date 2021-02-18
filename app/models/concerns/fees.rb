module Fees
  extend ActiveSupport::Concern

  included do
    def client_amount(total = amount)
      total + client_fee(total)
    end

    def client_fee(amount = self.amount)
      total = 0
      total += platform_fee(amount) if client_pays_fees?
      total + processing_fee(amount)
    end

    def freelancer_amount(total = amount)
      total - freelancer_fee(total)
    end

    def freelancer_fee(amount = self.amount)
      client_pays_fees? ? 0 : platform_fee(amount)
    end

    def platform_fee(total = amount)
      total * fee_percent
    end

    def processing_fee(total = amount)
      total * (pay_method&.fee_percent || 0)
    end

    def pay_method
      client.primary_pay_method
    end
  end
end
