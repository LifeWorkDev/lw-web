class Milestones::PayJob < ApplicationJob
  def perform(milestone)
    return unless milestone.payment_date?

    milestone.pay!
  end
end
