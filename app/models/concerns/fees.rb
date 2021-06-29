module Fees
  extend ActiveSupport::Concern

  included do
    def client_amount(amount: self.amount, pay_method: self.pay_method)
      amount + client_fee(amount: amount, pay_method: pay_method)
    end

    def client_fee(amount: self.amount, pay_method: self.pay_method)
      total = 0
      total += platform_fee(amount: amount) if client_pays_fees?
      total + processing_fee(amount: amount, pay_method: pay_method)
    end

    def freelancer_amount(amount: self.amount)
      amount - freelancer_fee(amount: amount)
    end

    def freelancer_fee(amount: self.amount)
      client_pays_fees? ? 0 : platform_fee(amount: amount)
    end

    def platform_fee(amount: self.amount)
      amount * fee_percent
    end

    def processing_fee(amount: self.amount, pay_method: self.pay_method)
      amount * (pay_method&.fee_percent || 0)
    end

    def pay_method
      client.primary_pay_method
    end
  end
end
