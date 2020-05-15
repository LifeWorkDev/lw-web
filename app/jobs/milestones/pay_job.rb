module Milestones
  class PayJob < Job
    def perform(milestone)
      super
      return unless milestone.payment_date?

      milestone.pay!
    end
  end
end
